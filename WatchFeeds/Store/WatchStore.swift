import Foundation
import SwiftData

@MainActor
final class WatchStore: ObservableObject {
    private let context: ModelContext
    @Published var error: String?

    init(modelContext: ModelContext) {
        self.context = modelContext
    }

    func fetchWatches() throws -> [Watch] {
        let descriptor = FetchDescriptor<Watch>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try context.fetch(descriptor)
    }

    func addWatch(name: String, type: WatchType, target: String) {
        let watch = Watch(name: name, type: type, target: target)
        context.insert(watch)
        save()
    }

    func delete(_ watch: Watch) {
        context.delete(watch)
        save()
    }

    func save() {
        do {
            try context.save()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func markChecked(_ watch: Watch) {
        watch.lastCheckedAt = .now
        save()
    }
}
