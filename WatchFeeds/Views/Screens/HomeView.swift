import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FeedItem.fetchedAt, order: .reverse) private var items: [FeedItem]
    @State private var isRefreshing = false
    @State private var includeRead = false
    let watchService: WatchService

    var filteredItems: [FeedItem] {
        if includeRead { return items }
        return items.filter { !$0.isRead }
    }

    var body: some View {
        NavigationStack {
            List(filteredItems) { item in
                NavigationLink(value: item) {
                    FeedRow(item: item)
                }
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await refreshAll() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Toggle(isOn: $includeRead) {
                        Text("Show Read")
                    }
                }
            }
            .refreshable {
                await refreshAll()
            }
            .navigationDestination(for: FeedItem.self) { item in
                ItemDetailView(item: item)
            }
        }
    }

    private func refreshAll() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        let fetchDescriptor = FetchDescriptor<Watch>()
        let watches = (try? modelContext.fetch(fetchDescriptor)) ?? []
        let store = FeedStore(modelContext: modelContext)
        for watch in watches {
            do {
                let items = try await watchService.refresh(watch: watch)
                store.addItems(items)
            } catch {
                print("Refresh failed: \(error)")
            }
        }
    }
}
