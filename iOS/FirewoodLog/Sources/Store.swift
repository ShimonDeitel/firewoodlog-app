import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var items: [FirewoodLogItem] = []
    @Published var isPro: Bool = false

    /// Free tier limit is intentionally well above seed data count so a fresh
    /// install never trips the paywall immediately.
    static let freeLimit = 15

    private let fileURL: URL

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
        fileURL = support.appendingPathComponent("firewoodlog_items.json")
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([FirewoodLogItem].self, from: data) else {
            items = [
        FirewoodLogItem(stackLocation: "Back Porch", cordAmount: "1.5", deliveryDate: "2025-09-10"),
        FirewoodLogItem(stackLocation: "Side Yard", cordAmount: "2.0", deliveryDate: "2026-01-05"),
        FirewoodLogItem(stackLocation: "Garage Rack", cordAmount: "0.5", deliveryDate: "2026-04-18")
            ]
            save()
            return
        }
        items = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    var canAddMore: Bool {
        isPro || items.count < Store.freeLimit
    }

    @discardableResult
    func add(_ item: FirewoodLogItem) -> Bool {
        guard canAddMore else { return false }
        items.insert(item, at: 0)
        save()
        return true
    }

    func update(_ item: FirewoodLogItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: FirewoodLogItem) {
        items.removeAll(where: { $0.id == item.id })
        save()
    }
}
