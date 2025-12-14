import SwiftUI
import SwiftData

struct WatchListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Watch.createdAt, order: .reverse) private var watches: [Watch]
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(watches) { watch in
                    NavigationLink(value: watch) {
                        VStack(alignment: .leading) {
                            Text(watch.name)
                            Text(watch.target)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Watchlist")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddWatchView()
            }
            .navigationDestination(for: Watch.self) { watch in
                WatchDetailView(watch: watch)
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        offsets.map { watches[$0] }.forEach(modelContext.delete)
    }
}
