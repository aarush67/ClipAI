import AppKit
import Foundation
import CryptoKit

class ClipboardService: ObservableObject {
    @Published var items: [ClipboardItem] = []
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private var lastContentHash: String?

    init() {
        startMonitoring()
        loadItems()
    }

    private func startMonitoring() {
        let interval = SettingsService.shared.pollingInterval
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        let currentChangeCount = pasteboard.changeCount

        if currentChangeCount != lastChangeCount {
            lastChangeCount = currentChangeCount
            processClipboardContent()
        }
    }

    private func processClipboardContent() {
        let pasteboard = NSPasteboard.general
        var item: ClipboardItem?
        var contentHash: String?

        if let string = pasteboard.string(forType: .string) {
            contentHash = SHA256.hash(data: string.data(using: .utf8)!).compactMap { String(format: "%02x", $0) }.joined()
            if contentHash == lastContentHash { return }
            if URL(string: string) != nil {
                item = ClipboardItem(content: string, type: "url", createdAt: Date(), thumbnail: nil)
            } else {
                item = ClipboardItem(content: string, type: "text", createdAt: Date(), thumbnail: nil)
            }
            print("Processed text/url: \(string.prefix(50))")
        } else if let image = pasteboard.data(forType: .tiff), SettingsService.shared.enableThumbnails, let thumbnail = thumbnailData(from: image) {
            contentHash = SHA256.hash(data: image).compactMap { String(format: "%02x", $0) }.joined()
            if contentHash == lastContentHash { return }
            item = ClipboardItem(content: "", type: "image", createdAt: Date(), thumbnail: thumbnail)
            print("Thumbnail generated: \(thumbnail.count) bytes")
        } else {
            print("No valid clipboard content or thumbnails disabled")
        }

        if let item = item {
            do {
                try DBService.shared.saveItem(item)
                lastContentHash = contentHash
                loadItems()
                if !SettingsService.shared.allowInfiniteHistory {
                    trimHistoryIfNeeded()
                }
                print("Saved item: type=\(item.type), thumbnail=\(item.thumbnail?.count ?? 0) bytes, pinned=\(item.isPinned)")
            } catch {
                print("Error saving item: \(error)")
            }
        }
    }

    private func thumbnailData(from data: Data) -> Data? {
        guard let image = NSImage(data: data) else {
            print("Failed to create NSImage from TIFF data")
            return nil
        }
        let size = NSSize(width: 100, height: 100)
        let scaledImage = NSImage(size: size)
        guard scaledImage.isValid else {
            print("Failed to create valid scaled NSImage")
            return nil
        }
        scaledImage.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: size), from: .zero, operation: .copy, fraction: 1.0)
        scaledImage.unlockFocus()
        guard let tiffData = scaledImage.tiffRepresentation else {
            print("Failed to get TIFF representation")
            return nil
        }
        print("Thumbnail created: \(tiffData.count) bytes")
        return tiffData
    }

    func loadItems() {
        do {
            items = try DBService.shared.fetchItems()
            print("Loaded \(items.count) items, pinned=\(items.filter { $0.isPinned }.count)")
            for item in items.filter({ $0.type == "image" }) {
                print("Image item: thumbnail=\(item.thumbnail?.count ?? 0) bytes, pinned=\(item.isPinned)")
            }
        } catch {
            print("Error loading items: \(error)")
        }
    }

    private func trimHistoryIfNeeded() {
        let maxItems = SettingsService.shared.maxHistorySize
        if items.count > maxItems {
            do {
                let itemsToDelete = items.filter { !$0.isPinned }.dropFirst(maxItems)
                for item in itemsToDelete {
                    try DBService.shared.deleteItem(item)
                }
                loadItems()
                print("Trimmed history to \(maxItems) items")
            } catch {
                print("Error trimming history: \(error)")
            }
        }
    }

    func copyToClipboard(_ item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        switch item.type {
        case "text", "url":
            pasteboard.setString(item.content, forType: .string)
            print("Copied \(item.type): \(item.content.prefix(50))")
        case "image":
            if let data = item.thumbnail, let image = NSImage(data: data) {
                pasteboard.writeObjects([image])
                print("Copied image: \(data.count) bytes")
            } else {
                print("Failed to copy image: no valid thumbnail")
            }
        default:
            print("Unknown item type: \(item.type)")
        }
    }
}
