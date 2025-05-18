import AppKit
import SwiftUI

class SettingsWindowController {
    static let shared = SettingsWindowController()
    private var window: NSWindow?

    private init() {}

    func showSettingsWindow() {
        if window == nil {
            let contentView = SettingsView()
            let hostingView = NSHostingView(rootView: contentView)
            
            window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 350, height: 300),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            window?.title = "ClipAI Settings"
            window?.center()
            window?.contentView = hostingView
            window?.isReleasedWhenClosed = false
            window?.level = .floating
        }
        
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
