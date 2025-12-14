import Foundation
import SwiftData

@Model
final class FeedItem: Identifiable {
    @Attribute(.unique) var id: UUID
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

    init(id: UUID = UUID(), title: String, url: URL, sourceName: String, publishedAt: Date?, fetchedAt: Date = .now, summary: String? = nil, content: String? = nil, isRead: Bool = false, isSaved: Bool = false, tags: [String] = [], watchId: UUID) {
        self.id = id
        self.title = title
        self.url = url
        self.sourceName = sourceName
        self.publishedAt = publishedAt
        self.fetchedAt = fetchedAt
        self.summary = summary
        self.content = content
        self.isRead = isRead
        self.isSaved = isSaved
        self.tags = tags
        self.watchId = watchId
    }
}
