import GRDB
import Foundation

class DBService {
    static let shared = DBService()
    private var dbQueue: DatabaseQueue

    private init() {
        let databaseURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("ClipAI/clipboard.db")
        try! FileManager.default.createDirectory(at: databaseURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        do {
            dbQueue = try DatabaseQueue(path: databaseURL.path)
            try migrator.migrate(dbQueue)
            print("Database initialized at \(databaseURL.path)")
        } catch {
            print("Failed to initialize database: \(error)")
            fatalError("Database initialization failed")
        }
    }

    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        // Initial table creation
        migrator.registerMigration("createClipboardItems") { db in
            try db.create(table: "clipboardItems") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("content", .text).notNull()
                t.column("type", .text).notNull()
                t.column("createdAt", .datetime).notNull()
                t.column("thumbnail", .blob)
                // isPinned not included here to avoid conflicts with existing databases
            }
            print("Migration: Created clipboardItems table")
        }
        
        // Add isPinned column for existing databases
        migrator.registerMigration("addIsPinnedColumn") { db in
            // Check if isPinned column exists using PRAGMA table_info
            let cursor = try Row.fetchCursor(db, sql: "PRAGMA table_info(clipboardItems)")
            var hasIsPinned = false
            while let row = try cursor.next() {
                if row["name"] as? String == "isPinned" {
                    hasIsPinned = true
                    break
                }
            }
            
            if !hasIsPinned {
                try db.alter(table: "clipboardItems") { t in
                    t.add(column: "isPinned", .boolean).notNull().defaults(to: false)
                }
                print("Migration: Added isPinned column to clipboardItems")
            } else {
                print("Migration: isPinned column already exists")
            }
        }
        
        return migrator
    }

    func saveItem(_ item: ClipboardItem) throws {
        try dbQueue.write { db in
            var mutableItem = item
            try mutableItem.insert(db)
            print("Saved item: id=\(mutableItem.id ?? -1), type=\(item.type), pinned=\(item.isPinned)")
        }
    }

    func fetchItems() throws -> [ClipboardItem] {
        try dbQueue.read { db in
            let items = try ClipboardItem
                .order(Column("isPinned").desc, Column("createdAt").desc)
                .fetchAll(db)
            print("Fetched \(items.count) items")
            return items
        }
    }

    func searchItems(query: String) throws -> [ClipboardItem] {
        try dbQueue.read { db in
            let items = try ClipboardItem
                .filter(Column("content").like("%\(query)%"))
                .order(Column("isPinned").desc, Column("createdAt").desc)
                .fetchAll(db)
            print("Searched for '\(query)', found \(items.count) items")
            return items
        }
    }

    func deleteItem(_ item: ClipboardItem) throws {
        try dbQueue.write { db in
            try item.delete(db)
            print("Deleted item: id=\(item.id ?? -1), content=\(item.content.prefix(50))")
        }
    }

    func clearHistory() throws {
        try dbQueue.write { db in
            try ClipboardItem.filter(!Column("isPinned")).deleteAll(db)
            print("Cleared non-pinned items")
        }
    }

    func togglePin(_ item: ClipboardItem) throws {
        try dbQueue.write { db in
            var mutableItem = item
            mutableItem.isPinned.toggle()
            try mutableItem.update(db)
            print("Toggled pin for item: id=\(item.id ?? -1), pinned=\(mutableItem.isPinned)")
        }
    }
}
