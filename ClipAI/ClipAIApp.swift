import SwiftUI
import Combine

@main
struct ClipAIApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    @ObservedObject var clipboardService = ClipboardService()
    @ObservedObject var settingsService = SettingsService.shared
    private let settingsWindowController = SettingsWindowController.shared
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        if settingsService.clearHistoryOnRestart {
            do {
                try DBService.shared.clearHistory()
            } catch {
                print("Error clearing history on launch: \(error)")
            }
        }

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateStatusItemIcon()

        settingsService.$menuBarIcon
            .sink { [weak self] _ in
                self?.updateStatusItemIcon()
            }
            .store(in: &cancellables)

        let menu = NSMenu()
        let view = NSHostingView(rootView: ContentView().environmentObject(clipboardService))
        view.frame = NSRect(x: 0, y: 0, width: 400, height: 500)
        let menuItem = NSMenuItem()
        menuItem.view = view
        menu.addItem(menuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "Clear History", action: #selector(clearHistory), keyEquivalent: "D"))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem?.menu = menu
    }

    private func updateStatusItemIcon() {
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: settingsService.menuBarIcon, accessibilityDescription: "ClipAI")
            print("Updated icon to: \(settingsService.menuBarIcon)")
        }
    }

    @objc private func openSettings() {
        settingsWindowController.showSettingsWindow()
    }

    @objc private func clearHistory() {
        do {
            try DBService.shared.clearHistory()
            clipboardService.loadItems()
        } catch {
            print("Error clearing history: \(error)")
        }
    }
}
