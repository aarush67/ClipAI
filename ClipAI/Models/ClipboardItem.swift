import GRDB
import Foundation

struct ClipboardItem: Codable, FetchableRecord, PersistableRecord, Identifiable, Equatable {
    var id: Int64?
    var content: String
    var type: String
    var createdAt: Date
    var thumbnail: Data?
    var isPinned: Bool

    static let databaseTableName = "clipboardItems"

    enum Columns {
        static let id = Column(CodingKeys.id)
        static let content = Column(CodingKeys.content)
        static let type = Column(CodingKeys.type)
        static let createdAt = Column(CodingKeys.createdAt)
        static let thumbnail = Column(CodingKeys.thumbnail)
        static let isPinned = Column(CodingKeys.isPinned)
    }

    init(content: String, type: String, createdAt: Date, thumbnail: Data?, isPinned: Bool = false) {
        self.content = content
        self.type = type
        self.createdAt = createdAt
        self.thumbnail = thumbnail
        self.isPinned = isPinned
    }

    // Equatable conformance
    static func ==(lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.content == rhs.content &&
        lhs.type == rhs.type &&
        lhs.createdAt == rhs.createdAt &&
        lhs.thumbnail == rhs.thumbnail &&
        lhs.isPinned == rhs.isPinned
    }
}
