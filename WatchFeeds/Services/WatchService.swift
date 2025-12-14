import Foundation
import CryptoKit
import os.log

protocol WatchFetching {
    func refresh(watch: Watch) async throws -> [FeedItem]
}

final class WatchService: WatchFetching {
    private let session: URLSession
    private let rssParser: RSSParser
    private let logger = Logger(subsystem: "WatchFeeds", category: "WatchService")

    init(session: URLSession = .shared, rssParser: RSSParser = RSSParser()) {
        self.session = session
        self.rssParser = rssParser
    }

    func refresh(watch: Watch) async throws -> [FeedItem] {
        switch watch.type {
        case .rss:
            return try await fetchRSS(watch: watch)
        case .website:
            return try await fetchWebsite(watch: watch)
        case .topic:
            return []
        }
    }

    private func fetchRSS(watch: Watch) async throws -> [FeedItem] {
        guard let url = URL(string: watch.target) else { return [] }
        let (data, _) = try await session.data(from: url)
        let rssItems = rssParser.parse(data: data)
        return rssItems.compactMap { item in
            guard let linkURL = URL(string: item.link) else { return nil }
            return FeedItem(
                title: item.title.isEmpty ? watch.name : item.title,
                url: linkURL,
                sourceName: watch.name,
                publishedAt: item.pubDate,
                fetchedAt: .now,
                summary: item.description,
                content: nil,
                isRead: false,
                isSaved: false,
                tags: [],
                watchId: watch.id
            )
        }
    }

    private func fetchWebsite(watch: Watch) async throws -> [FeedItem] {
        guard let url = URL(string: watch.target) else { return [] }
        let (data, response) = try await session.data(from: url)
        let htmlString = String(data: data, encoding: .utf8) ?? ""
        let digest = sha256String(htmlString)
        let etag = (response as? HTTPURLResponse)?.value(forHTTPHeaderField: "ETag")
        let lastModified = (response as? HTTPURLResponse)?.value(forHTTPHeaderField: "Last-Modified")
        let title = "Updated: \(url.host ?? watch.name)"

        var metadataComponents: [String] = []
        if let etag { metadataComponents.append("ETag: \(etag)") }
        if let lastModified { metadataComponents.append("Last-Modified: \(lastModified)") }
        metadataComponents.append("SHA: \(digest)")

        let summary = metadataComponents.joined(separator: "\n")
        return [FeedItem(
            title: title,
            url: url,
            sourceName: watch.name,
            publishedAt: nil,
            fetchedAt: .now,
            summary: summary,
            content: htmlString,
            isRead: false,
            isSaved: false,
            tags: [],
            watchId: watch.id
        )]
    }

    private func sha256String(_ string: String) -> String {
        let data = Data(string.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
