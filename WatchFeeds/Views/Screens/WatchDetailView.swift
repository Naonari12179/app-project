import SwiftUI
import SwiftData

struct WatchDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var searchText: String = ""
    @State private var includeRead = false
    @State private var isRefreshing = false
    @State private var errorMessage: String?
    var watch: Watch
    private let watchService = WatchService()

    var body: some View {
        let predicate: Predicate<FeedItem> = {
            if includeRead && searchText.isEmpty {
                return #Predicate { $0.watchId == watch.id }
            } else if includeRead {
                let text = searchText.lowercased()
                return #Predicate { $0.watchId == watch.id && ($0.title.lowercased().contains(text) || ($0.summary ?? "").lowercased().contains(text)) }
            } else if searchText.isEmpty {
                return #Predicate { $0.watchId == watch.id && $0.isRead == false }
            } else {
                let text = searchText.lowercased()
                return #Predicate { $0.watchId == watch.id && $0.isRead == false && ($0.title.lowercased().contains(text) || ($0.summary ?? "").lowercased().contains(text)) }
            }
        }()

        return NavigationStack {
            ItemList(predicate: predicate, title: watch.name, refreshAction: refresh)
                .searchable(text: $searchText)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            Task { await refresh() }
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
                .alert("Error", isPresented: Binding(value: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil }))) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage ?? "")
                }
        }
    }

    private func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        do {
            let items = try await watchService.refresh(watch: watch)
            let store = FeedStore(modelContext: modelContext)
            store.addItems(items)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct ItemList: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [FeedItem]
    var title: String
    var refreshAction: () async -> Void

    init(predicate: Predicate<FeedItem>, title: String, refreshAction: @escaping () async -> Void) {
        self.title = title
        self.refreshAction = refreshAction
        _items = Query(filter: predicate, sort: [SortDescriptor(\.fetchedAt, order: .reverse)])
    }

    var body: some View {
        List(items) { item in
            NavigationLink(value: item) {
                FeedRow(item: item)
            }
        }
        .navigationTitle(title)
        .refreshable {
            await refreshAction()
        }
        .navigationDestination(for: FeedItem.self) { item in
            ItemDetailView(item: item)
        }
    }
}
