import Foundation
import SwiftData

@MainActor
final class FeedStore: ObservableObject {
    private let context: ModelContext
    @Published var error: String?

    init(modelContext: ModelContext) {
        self.context = modelContext
    }

    func fetchItems(for watch: Watch? = nil, includeRead: Bool = true, searchText: String = "") throws -> [FeedItem] {
        var predicates: [Predicate<FeedItem>] = []
        if let watch {
            predicates.append(#Predicate { $0.watchId == watch.id })
        }
        if !includeRead {
            predicates.append(#Predicate { $0.isRead == false })
        }
        if !searchText.isEmpty {
            let text = searchText.lowercased()
            predicates.append(#Predicate { $0.title.lowercased().contains(text) || ($0.summary ?? "").lowercased().contains(text) })
        }
        let compound: Predicate<FeedItem>? = predicates.isEmpty ? nil : predicates.dropFirst().reduce(predicates.first!) { acc, next in
            #Predicate { acc.evaluate(with: $0) && next.evaluate(with: $0) }
        }
        let descriptor = FetchDescriptor<FeedItem>(predicate: compound, sortBy: [SortDescriptor(\.fetchedAt, order: .reverse)])
        return try context.fetch(descriptor)
    }

    func addItems(_ items: [FeedItem]) {
        items.forEach { context.insert($0) }
        save()
    }

    func toggleRead(_ item: FeedItem) {
        item.isRead.toggle()
        save()
    }

    func toggleSaved(_ item: FeedItem) {
        item.isSaved.toggle()
        save()
    }

    func deleteAll(for watch: Watch) throws {
        let descriptor = FetchDescriptor<FeedItem>(predicate: #Predicate { $0.watchId == watch.id })
        let items = try context.fetch(descriptor)
        items.forEach { context.delete($0) }
        save()
    }

    func save() {
        do {
            try context.save()
        } catch {
            self.error = error.localizedDescription
        }
    }
}
