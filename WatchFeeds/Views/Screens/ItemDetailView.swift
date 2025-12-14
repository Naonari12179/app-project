import SwiftUI
import SwiftData
import UIKit

struct ItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showShare = false
    var item: FeedItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(item.title)
                    .font(.title2)
                    .bold()
                Text(item.sourceName)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                HStack {
                    if let publishedAt = item.publishedAt {
                        Label(publishedAt.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                    }
                    Label(item.fetchedAt.formatted(date: .numeric, time: .shortened), systemImage: "clock")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                if let summary = item.summary {
                    Text(summary)
                        .font(.body)
                }
                if let content = item.content {
                    Text(content)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Detail")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: toggleSaved) {
                    Image(systemName: item.isSaved ? "bookmark.fill" : "bookmark")
                }
                Button(action: toggleRead) {
                    Image(systemName: item.isRead ? "envelope.open" : "envelope")
                }
                Button {
                    if let url = URL(string: item.url.absoluteString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Image(systemName: "safari")
                }
            }
        }
        .onAppear {
            markRead()
        }
    }

    private func toggleRead() {
        let store = FeedStore(modelContext: modelContext)
        store.toggleRead(item)
    }

    private func toggleSaved() {
        let store = FeedStore(modelContext: modelContext)
        store.toggleSaved(item)
    }

    private func markRead() {
        if !item.isRead {
            toggleRead()
        }
    }
}
