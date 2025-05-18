import Foundation

class SettingsService: ObservableObject {
    static let shared = SettingsService()
    
    @Published var maxHistorySize: Int {
        didSet {
            UserDefaults.standard.set(maxHistorySize, forKey: "maxHistorySize")
        }
    }
    
    @Published var pollingInterval: Double {
        didSet {
            UserDefaults.standard.set(pollingInterval, forKey: "pollingInterval")
        }
    }
    
    @Published var enableThumbnails: Bool {
        didSet {
            UserDefaults.standard.set(enableThumbnails, forKey: "enableThumbnails")
        }
    }
    
    @Published var clearHistoryOnRestart: Bool {
        didSet {
            UserDefaults.standard.set(clearHistoryOnRestart, forKey: "clearHistoryOnRestart")
        }
    }
    
    @Published var showTimestamps: Bool {
        didSet {
            UserDefaults.standard.set(showTimestamps, forKey: "showTimestamps")
        }
    }
    
    @Published var allowInfiniteHistory: Bool {
        didSet {
            UserDefaults.standard.set(allowInfiniteHistory, forKey: "allowInfiniteHistory")
        }
    }
    
    @Published var menuBarIcon: String {
        didSet {
            UserDefaults.standard.set(menuBarIcon, forKey: "menuBarIcon")
        }
    }
    
    private init() {
        self.maxHistorySize = UserDefaults.standard.integer(forKey: "maxHistorySize") > 0 ? UserDefaults.standard.integer(forKey: "maxHistorySize") : 100
        self.pollingInterval = UserDefaults.standard.double(forKey: "pollingInterval") > 0 ? UserDefaults.standard.double(forKey: "pollingInterval") : 0.5
        self.enableThumbnails = UserDefaults.standard.object(forKey: "enableThumbnails") as? Bool ?? true
        self.clearHistoryOnRestart = UserDefaults.standard.object(forKey: "clearHistoryOnRestart") as? Bool ?? false
        self.showTimestamps = UserDefaults.standard.object(forKey: "showTimestamps") as? Bool ?? false
        self.allowInfiniteHistory = UserDefaults.standard.object(forKey: "allowInfiniteHistory") as? Bool ?? false
        self.menuBarIcon = UserDefaults.standard.string(forKey: "menuBarIcon") ?? "doc.on.clipboard"
    }
}
