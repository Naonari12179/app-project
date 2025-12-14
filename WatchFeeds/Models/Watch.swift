import Foundation
import SwiftData

enum WatchType: String, Codable, CaseIterable, Identifiable {
    case rss
    case website
    case topic

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .rss: return "RSS"
        case .website: return "Website"
        case .topic: return "Topic"
        }
    }
}

@Model
final class Watch: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: WatchType
    var target: String
    var createdAt: Date
    var lastCheckedAt: Date?
    var notes: String?

    init(id: UUID = UUID(), name: String, type: WatchType, target: String, createdAt: Date = .now, lastCheckedAt: Date? = nil, notes: String? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.target = target
        self.createdAt = createdAt
        self.lastCheckedAt = lastCheckedAt
        self.notes = notes
    }
}
