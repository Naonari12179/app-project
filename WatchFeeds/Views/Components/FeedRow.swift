import SwiftUI

struct FeedRow: View {
    var item: FeedItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(2)
                if item.isSaved {
                    Image(systemName: "bookmark.fill")
                        .foregroundStyle(.blue)
                }
            }
            Text(item.sourceName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack {
                if let publishedAt = item.publishedAt {
                    Text(publishedAt, style: .date)
                }
                Text(item.fetchedAt, style: .time)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
