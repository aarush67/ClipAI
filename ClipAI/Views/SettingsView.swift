import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = SettingsService.shared
    @EnvironmentObject var clipboardService: ClipboardService
    @State private var isClearingHistory = false

    var body: some View {
        Form {
            Section(header: Text("Clipboard Settings").font(.headline)) {
                Toggle("Allow Infinite History", isOn: $settings.allowInfiniteHistory)
                    .controlSize(.regular)
                
                Picker("Maximum History Size", selection: $settings.maxHistorySize) {
                    Text("50").tag(50)
                    Text("100").tag(100)
                    Text("500").tag(500)
                }
                .pickerStyle(.menu)
                .controlSize(.regular)
                .disabled(settings.allowInfiniteHistory)
                
                Picker("Polling Interval", selection: $settings.pollingInterval) {
                    Text("0.5 seconds").tag(0.5)
                    Text("1 second").tag(1.0)
                    Text("2 seconds").tag(2.0)
                }
                .pickerStyle(.menu)
                .controlSize(.regular)
                
                Toggle("Enable Image Thumbnails", isOn: $settings.enableThumbnails)
                    .controlSize(.regular)
                
                Toggle("Clear History on Restart", isOn: $settings.clearHistoryOnRestart)
                    .controlSize(.regular)
                
                Toggle("Show Timestamps", isOn: $settings.showTimestamps)
                    .controlSize(.regular)
                
                Button(action: {
                    isClearingHistory = true
                    do {
                        try DBService.shared.clearHistory()
                        clipboardService.loadItems()
                    } catch {
                        print("Error clearing history: \(error)")
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isClearingHistory = false
                    }
                }) {
                    Text(isClearingHistory ? "Clearing..." : "Clear History")
                        .frame(maxWidth: .infinity)
                }
                .controlSize(.regular)
                .disabled(isClearingHistory)
            }
            
            Section(header: Text("Appearance").font(.headline)) {
                Picker("Menu Bar Icon", selection: $settings.menuBarIcon) {
                    Text("Clipboard").tag("doc.on.clipboard")
                    Text("Document").tag("doc.text")
                    Text("Paperclip").tag("paperclip")
                    Text("Stack").tag("square.on.square")
                }
                .pickerStyle(.menu)
                .controlSize(.regular)
            }
        }
        .padding()
        .frame(width: 350, height: 400)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .animation(.easeInOut, value: settings.allowInfiniteHistory) // Animate specific property
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(ClipboardService())
    }
}
