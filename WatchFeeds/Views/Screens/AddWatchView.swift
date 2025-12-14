import SwiftUI
import SwiftData

struct AddWatchView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var name: String = ""
    @State private var target: String = ""
    @State private var type: WatchType = .rss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Type")) {
                    Picker("Watch Type", selection: $type) {
                        ForEach(WatchType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Info")) {
                    TextField("Name", text: $name)
                    TextField(type == .topic ? "Keyword / Ticker" : "URL", text: $target)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                }
            }
            .navigationTitle("Add Watch")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: { dismiss() })
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(name.isEmpty || target.isEmpty)
                }
            }
        }
    }

    private func save() {
        let store = WatchStore(modelContext: modelContext)
        store.addWatch(name: name, type: type, target: target)
        dismiss()
    }
}
