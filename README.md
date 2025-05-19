# ClipAI

ClipAI is a modern, AI-powered clipboard manager for macOS, designed to enhance productivity with a sleek, Apple-inspired interface. It captures text, URLs, and images from your clipboard, offering features like semantic search, pinned items, hover-based shortcuts, and infinite history. Built with SwiftUI and GRDB, ClipAI is lightweight, fast, and competitive with apps like Paste and Maccy.

## Features

- **Clipboard Capture**: Automatically saves text, URLs, and images copied to the clipboard.
- **AI-Powered Search**: Uses semantic search (via `NaturalLanguage.framework`) to find items by meaning (e.g., search "canine" to find "dog" or "puppy").
- **Pinned Items**: Pin important items to keep them at the top of the list, preserved during history clearing.
- **Hover Shortcuts**: Hover over an item to show shortcuts:
  - `Option + Delete`: Delete the item.
- **Clickable Content**: Click text or thumbnails to copy items back to the clipboard. URLs show hover underlines for clarity.
- **Thumbnails**: Displays 50x50px previews for images (toggleable in settings).
- **Infinite History**: Stores unlimited clipboard items (optional, configurable in settings).
- **Duplicate Prevention**: Merges duplicate items to keep the list clean.
- **Clear History**: Clear non-pinned items via `Cmd + Shift + D` or settings.
- **Dynamic Menu Bar Icons**: Choose from multiple icon styles, updated instantly.
- **Modern UI**: Apple-inspired design with translucent backgrounds, rounded corners, and smooth animations.
- **Keyboard Shortcuts**:
  - `Cmd + T`: Focus the search bar.
  - `Cmd + ,`: Open settings.
  - `Cmd + Shift + D`: Clear history.
- **Settings**:
  - Toggle thumbnails, timestamps, infinite history, and clear-on-restart.
  - Customize menu bar icon.
- **Persistent Storage**: Uses GRDB for reliable storage at `~/Library/Application Support/ClipAI/clipboard.db`.

## Screenshots

*(Add screenshots of the main window, hover shortcuts, and settings here for visual appeal.)*

## Requirements

- macOS 12.0 or later
- Xcode 14.0 or later (for development)
- Swift 5.5 or later (for development)

## Installation

### For Users

1. **Download the Precompiled App**:
   - Visit the [GitHub Releases](https://github.com/aarush67/ClipAI/releases) page.
   - Download the latest `.zip` file from the releases tab.
   - Open the `.zip` file and drag `ClipAI.app` to the `/Applications` folder.

2. **Grant Permissions**:
   - Launch ClipAI from `/Applications`.
   - Enable Accessibility permissions in **System Settings > Privacy & Security > Accessibility** to allow key event capture for hover shortcuts.

### For Developers (Compiling from Source)

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/aarush67/ClipAI.git
   cd ClipAI
   ```

2. **Open in Xcode**:
   - Open `ClipAI.xcworkspace` (not `.xcodeproj`) to include Swift Package Manager dependencies.

3. **Install Dependencies**:
   - Add GRDB via Swift Package Manager:
     - URL: `https://github.com/groue/GRDB.swift.git`
     - Version: Latest (e.g., `6.29.0`)
   - Run **File > Packages > Update to Latest Package Versions**.
   - Verify `ClipAI.xcworkspace/xcshareddata/swiftpm/Package.resolved`.

4. **Link Frameworks**:
   - In **Build Phases > Link Binary With Libraries**, ensure:
     - `NaturalLanguage.framework`
     - `CryptoKit.framework`
     - `Combine.framework`

5. **Set Deployment Target**:
   - Set the project’s deployment target to macOS 12.0+ in **Build Settings**.

6. **Resolve Common Issues**:
   - Clean build folder: **Product > Clean Build Folder** (`Shift + Cmd + K`).
   - Delete caches:
     ```bash
     rm -rf ~/Library/Caches/org.swift.swiftpm
     rm -rf ~/Library/Developer/Xcode/DerivedData
     ```
   - Reset package caches: **File > Packages > Reset Package Caches**.
   - If building on an external drive (`/Volumes/ExtremeSSD`), ensure it’s writable:
     ```bash
     chmod -R u+rw /Volumes/ExtremeSSD/ClipAI
     ```
   - Move to `~/Documents` if issues persist:
     ```bash
     mv /Volumes/ExtremeSSD/ClipAI ~/Documents/ClipAI
     ```

7. **Build and Run**:
   - Press `Cmd + B` to build.
   - Press `Cmd + R` to run.
   - To distribute, archive the app (**Product > Archive**) and export a notarized app.

## Usage

1. **Launch ClipAI**:
   - Open the app from `/Applications` or run it from Xcode.
   - A menu bar icon appears, indicating ClipAI is active.

2. **Copy Items**:
   - Copy text, URLs, or images. They’ll appear in the main window, sorted by `isPinned` (descending) and `createdAt` (descending).

3. **Interact with Items**:
   - **Hover**: See “⌥ + Delete to delete” and “⌥ + P to pin/unpin”.
   - **Shortcuts**:
     - `Option + Delete`: Delete the hovered item.
     - `Option + P`: Pin or unpin the hovered item.
   - **Click**: Click text or thumbnails to copy to the clipboard.
   - **Pin**: Click the pin icon to toggle pinning.

4. **Search**:
   - Press `Cmd + T` to focus the search bar.
   - Enter a query (e.g., “canine” to find “dog” or “puppy”).

5. **Manage History**:
   - Clear non-pinned items with `Cmd + Shift + D` or via settings.
   - Pin items to preserve them during clearing.

6. **Customize Settings**:
   - Open settings with `Cmd + ,`, or click the gear icon.
   - Toggle thumbnails, timestamps, infinite history, clear-on-restart.
   - Change the menu bar icon.

7. **Check Logs**:
   - Open **View > Debug Area > Show Debug Area** in Xcode to see logs for hover events, key actions, and database operations.

## Project Structure

```
ClipAI/
├── ClipAIApp.swift              # App entry point, menu bar setup
├── Models/
│   └── ClipboardItem.swift      # Data model for clipboard items
├── Views/
│   ├── ContentView.swift        # Main window with list and hover shortcuts
│   └── SettingsView.swift       # Settings window
├── Services/
│   ├── ClipboardService.swift   # Clipboard monitoring and copying
│   ├── DBService.swift          # Database operations with GRDB
│   ├── SettingsService.swift    # Settings management
│   └── SettingsWindowController.swift # Settings window controller
├── Utils/
│   └── AISearch.swift           # Semantic search with NaturalLanguage
├── Resources/
│   └── Assets.xcassets          # App icons and assets
```

## Database

- **Location**: `~/Library/Application Support/ClipAI/clipboard.db`
- **Schema**: Table `clipboardItems` with columns:
  - `id`: Auto-incremented primary key (`Int64`)
  - `content`: Text content (`String`)
  - `type`: Item type (e.g., “text”, “url”, “image”) (`String`)
  - `createdAt`: Timestamp (`Date`)
  - `thumbnail`: Image thumbnail data (`Data?`)
  - `isPinned`: Pin status (`Bool`, default `false`)
- **Clear Database** (if needed):
  ```bash
  rm ~/Library/Application\ Support/ClipAI/clipboard.db
  ```
  *Note*: This erases all clipboard history. Back up first:
  ```bash
  cp ~/Library/Application\ Support/ClipAI/clipboard.db ~/Desktop/clipboard_backup.db
  ```

## Troubleshooting

- **Hover Shortcuts Not Working**:
  - Check logs for “Hover: true”, “Toggled pin”, or “Deleted item”.
  - Ensure Accessibility permissions are enabled (**System Settings > Privacy & Security > Accessibility**).
  - Verify hover overlay visibility by temporarily setting `.background(.red)` in `ClipboardItemView`.
  - Test key events by adding to `startMonitoringKeys`:
    ```swift
    print("Key event: characters=\(event.charactersIgnoringModifiers ?? ""), keyCode=\(event.keyCode), modifiers=\(event.modifierFlags.rawValue)")
    ```

- **Storage Issues**:
  - Check logs for “Migration: Added isPinned column” and “Saved item”.
  - Verify schema in `DBService.init`:
    ```swift
    print("Table schema: \(try dbQueue.read { try $0.columns(in: "clipboardItems").map { $0.name } })")
    ```
    Expected: `["id", "content", "type", "createdAt", "thumbnail", "isPinned"]`.
  - Clear database if needed (see [Database](#database)).

- **Thumbnails Not Showing**:
  - Check logs for “Thumbnail created: X bytes” or “Failed to create NSImage”.
  - Add to `ClipboardItemView`:
    ```swift
    print("Thumbnail data: \(item.thumbnail?.base64EncodedString() ?? "nil")")
    ```
  - Ensure `enableThumbnails` is enabled in settings.

- **GRDB Dependency Issues**:
  - Delete caches:
    ```bash
    rm -rf ~/Library/Caches/org.swift.swiftpm
    rm -rf ~/Library/Developer/Xcode/DerivedData
    ```
  - Reset package caches: **File > Packages > Reset Package Caches**.
  - Re-add GRDB via **File > Add Packages**.
  - Run:
    ```bash
    xcodebuild -resolvePackageDependencies
    ```

- **External Drive Issues**:
  - Ensure `/Volumes/ExtremeSSD` is writable:
    ```bash
    chmod -R u+rw /Volumes/ExtremeSSD/ClipAI
    ```
  - Move to `~/Documents` if issues persist:
    ```bash
    mv /Volumes/ExtremeSSD/ClipAI ~/Documents/ClipAI
    ```

## Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/your-feature`).
3. Commit changes (`git commit -m "Add your feature"`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a pull request.

## Future Enhancements

- Grid view for image thumbnails.
- Support for rich text and file copying.
- Search history or categories.
- “Paste Now” shortcut.
- iCloud sync for clipboard history.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For issues or feature requests, open a GitHub issue or contact [your-email@example.com](mailto:your-email@example.com).

---

*Built with ❤️ for macOS users.*
