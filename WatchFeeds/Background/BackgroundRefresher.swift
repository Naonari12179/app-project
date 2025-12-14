import Foundation
import BackgroundTasks
import SwiftData

final class BackgroundRefresher {
    private let modelContainer: ModelContainer
    private let watchService: WatchService

    init(modelContainer: ModelContainer, watchService: WatchService = WatchService()) {
        self.modelContainer = modelContainer
        self.watchService = watchService
    }

    func scheduleRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.example.watchfeeds.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 1 * 60 * 60)
        try? BGTaskScheduler.shared.submit(request)
    }

    func performBackgroundRefresh() async {
        let context = ModelContext(modelContainer)
        let feedStore = FeedStore(modelContext: context)
        let descriptor = FetchDescriptor<Watch>()
        let watches = (try? context.fetch(descriptor)) ?? []
        for watch in watches {
            do {
                let items = try await watchService.refresh(watch: watch)
                feedStore.addItems(items)
            } catch {
                print("Background refresh failed: \(error)")
            }
        }
        scheduleRefresh()
    }
}
