import SwiftUI
import AppKit

struct ContentView: View {
    @EnvironmentObject var clipboardService: ClipboardService
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Search clipboard...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .focused($isSearchFocused)
                    .padding(.vertical, 8)
                Button(action: {
                    SettingsWindowController.shared.showSettingsWindow()
                }) {
                    Image(systemName: "gearshape")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal)
            .background(.ultraThinMaterial)

            List {
                ForEach(filteredItems) { item in
                    ClipboardItemView(item: item)
                        .transition(.opacity.combined(with: .slide))
                }
            }
            .animation(.easeInOut, value: filteredItems)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .frame(width: 400, height: 500)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isSearchFocused = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willBecomeActiveNotification)) { _ in
            isSearchFocused = false
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "t" {
                    self.isSearchFocused = true
                    return nil
                }
                return event
            }
        }
    }

    private var filteredItems: [ClipboardItem] {
        if searchText.isEmpty {
            return clipboardService.items
        } else {
            return AISearch.search(query: searchText, items: clipboardService.items)
        }
    }
}

struct ClipboardItemView: View {
    let item: ClipboardItem
    @EnvironmentObject var clipboardService: ClipboardService
    @ObservedObject var settings = SettingsService.shared
    @State private var isHovered = false
    @State private var eventMonitor: Any?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack {
                // Thumbnail or Icon
                if item.type == "image", let data = item.thumbnail, let nsImage = NSImage(data: data) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(isHovered ? Color.accentColor : .clear, lineWidth: 2)
                        )
                        .onTapGesture {
                            clipboardService.copyToClipboard(item)
                            print("Clicked image thumbnail")
                        }
                } else {
                    Image(systemName: item.type == "url" ? "link" : "doc.text")
                        .frame(width: 50, height: 50)
                        .foregroundColor(.secondary)
                }

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Button(action: {
                        clipboardService.copyToClipboard(item)
                        print("Clicked text: \(item.content.prefix(50))")
                    }) {
                        Text(item.content.isEmpty ? "Image" : item.content)
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .foregroundColor(item.type == "url" && isHovered ? .blue : .primary)
                            .underline(item.type == "url" && isHovered)
                    }
                    .buttonStyle(.plain)

                    if settings.showTimestamps {
                        Text(item.createdAt, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Pin Button
                Button(action: {
                    do {
                        try DBService.shared.togglePin(item)
                        clipboardService.loadItems()
                    } catch {
                        print("Error toggling pin: \(error)")
                    }
                }) {
                    Image(systemName: item.isPinned ? "pin.fill" : "pin")
                        .foregroundColor(item.isPinned ? .accentColor : .secondary)
                }
                .buttonStyle(.borderless)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(isHovered ? Color.secondary.opacity(0.1) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Hover Shortcut Overlay
            if isHovered {
                VStack {
                    Text("⌥ + Delete to delete")
                        .font(.caption)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .padding(4)
                .transition(.opacity)
            }

        }
        .animation(.easeInOut, value: isHovered)
        .onHover { hovering in
            isHovered = hovering
            print("Hover: \(hovering) for item: \(item.content.prefix(50))")
            if hovering {
                startMonitoringKeys()
            } else {
                stopMonitoringKeys()
            }
        }
        .onDisappear {
            stopMonitoringKeys()
        }
    }

    private func startMonitoringKeys() {
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard isHovered else { return event }
            
            let isOptionPressed = event.modifierFlags.contains(.option)
            let characters = event.charactersIgnoringModifiers?.lowercased() ?? ""
            
            if isOptionPressed && characters == "p" {
                do {
                    try DBService.shared.togglePin(item)
                    clipboardService.loadItems()
                    print("Toggled pin for item: \(item.content.prefix(50))")
                    return nil // Consume the event
                } catch {
                    print("Error toggling pin: \(error)")
                }
            } else if isOptionPressed && event.keyCode == 51 { // 51 is the keyCode for Delete
                do {
                    try DBService.shared.deleteItem(item)
                    clipboardService.loadItems()
                    print("Deleted item: \(item.content.prefix(50))")
                    return nil // Consume the event
                } catch {
                    print("Error deleting item: \(error)")
                }
            }
            
            return event
        }
    }

    private func stopMonitoringKeys() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
            print("Stopped key monitoring for item: \(item.content.prefix(50))")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ClipboardService())
    }
}
