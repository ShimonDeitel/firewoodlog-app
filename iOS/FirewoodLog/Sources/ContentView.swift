import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingItem: FirewoodLogItem?

    var body: some View {
        Group {

        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.items.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(store.items) { item in
                            row(for: item)
                                .listRowBackground(Theme.background)
                                .contentShape(Rectangle())
                                .onTapGesture { editingItem = item }
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Theme.background)
                }
            }
            .navigationTitle("Firewood Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                    .foregroundColor(Theme.accent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                    .foregroundColor(Theme.accent)
                }
            }
            .sheet(isPresented: $showingAdd) {
                EditItemView(item: nil)
            }
            .sheet(item: $editingItem) { item in
                EditItemView(item: item)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
        .tint(Theme.accent)

        }

    }

    private func row(for item: FirewoodLogItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.stackLocation)
                .font(Theme.headlineFont)
                .foregroundColor(Theme.textPrimary)
            Text(item.cordAmount)
                .font(Theme.bodyFont)
                .foregroundColor(Theme.textSecondary)
            Text(item.deliveryDate)
                .font(Theme.captionFont)
                .foregroundColor(Theme.textSecondary)
        }
        .padding(.vertical, 4)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(Theme.accent)
            Text("No Stacks yet")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.textPrimary)
            Text("Tap + to add your first one.")
                .font(Theme.bodyFont)
                .foregroundColor(Theme.textSecondary)
        }
    }

}

struct EditItemView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    var item: FirewoodLogItem?

    @State private var stackLocation: String = ""
    @State private var cordAmount: String = ""
    @State private var deliveryDate: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Stack Location") {
                    TextField("Stack Location", text: $stackLocation)
                        .accessibilityIdentifier("fieldStackLocation")
                }
                Section("Cord Amount") {
                    TextField("Cord Amount", text: $cordAmount)
                        .accessibilityIdentifier("fieldCordAmount")
                }
                Section("Delivery Date") {
                    TextField("Delivery Date", text: $deliveryDate)
                        .accessibilityIdentifier("fieldDeliveryDate")
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationTitle(item == nil ? "Add Stack" : "Edit Stack")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .accessibilityIdentifier("saveButton")
                    .disabled(stackLocation.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let item {
                    stackLocation = item.stackLocation
                    cordAmount = item.cordAmount
                    deliveryDate = item.deliveryDate
                }
            }
        }
    }

    private func save() {
        if var existing = item {
            existing.stackLocation = stackLocation
            existing.cordAmount = cordAmount
            existing.deliveryDate = deliveryDate
            store.update(existing)
        } else {
            let newItem = FirewoodLogItem(stackLocation: stackLocation, cordAmount: cordAmount, deliveryDate: deliveryDate)
            store.add(newItem)
        }
        dismiss()
    }
}
