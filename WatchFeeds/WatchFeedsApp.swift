import SwiftUI
import SwiftData

@main
struct WatchFeedsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Watch.self,
            FeedItem.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [configuration])
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(sharedModelContainer)
        }
        .backgroundTask(.appRefresh("com.example.watchfeeds.refresh")) {
            let refresher = BackgroundRefresher(modelContainer: sharedModelContainer)
            await refresher.performBackgroundRefresh()
        }
    }
}
