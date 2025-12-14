import Foundation

struct WatchDTO: Codable, Identifiable {
    var id: UUID
    var name: String
    var type: WatchType
    var target: String
    var createdAt: Date
    var lastCheckedAt: Date?
    var notes: String?

    init(from model: Watch) {
        self.id = model.id
        self.name = model.name
        self.type = model.type
        self.target = model.target
        self.createdAt = model.createdAt
        self.lastCheckedAt = model.lastCheckedAt
        self.notes = model.notes
    }
}

struct FeedItemDTO: Codable, Identifiable {
    var id: UUID
    var title: String
    var url: URL
    var sourceName: String
    var publishedAt: Date?
    var fetchedAt: Date
    var summary: String?
    var content: String?
    var isRead: Bool
    var isSaved: Bool
    var tags: [String]
    var watchId: UUID

    init(from model: FeedItem) {
        self.id = model.id
        self.title = model.title
        self.url = model.url
        self.sourceName = model.sourceName
        self.publishedAt = model.publishedAt
        self.fetchedAt = model.fetchedAt
        self.summary = model.summary
        self.content = model.content
        self.isRead = model.isRead
        self.isSaved = model.isSaved
        self.tags = model.tags
        self.watchId = model.watchId
    }
}
