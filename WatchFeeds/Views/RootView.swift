import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    private var watchService = WatchService()

    var body: some View {
        TabView {
            HomeView(watchService: watchService)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            WatchListView()
                .tabItem {
                    Label("Watchlist", systemImage: "eye.fill")
                }
            SavedView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark")
                }
        }
        .modelContext(modelContext)
    }
}

struct SavedView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FeedItem.fetchedAt, order: .reverse, filter: #Predicate { $0.isSaved == true })
    private var items: [FeedItem]

    var body: some View {
        NavigationStack {
            List(items) { item in
                NavigationLink(value: item) {
                    FeedRow(item: item)
                }
            }
            .navigationTitle("Saved")
            .navigationDestination(for: FeedItem.self) { item in
                ItemDetailView(item: item)
            }
        }
    }
}
