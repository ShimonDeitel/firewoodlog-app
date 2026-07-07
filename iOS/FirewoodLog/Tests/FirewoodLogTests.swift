import XCTest
@testable import FirewoodLog

@MainActor
final class StoreTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
        store.items = []
        store.isPro = false
    }

    func testAddItem() {
        let item = FirewoodLogItem(stackLocation: "A", cordAmount: "B", deliveryDate: "C")
        let added = store.add(item)
        XCTAssertTrue(added)
        XCTAssertEqual(store.items.count, 1)
    }

    func testFreeLimitBlocksAdd() {
        for i in 0..<Store.freeLimit {
            store.add(FirewoodLogItem(stackLocation: "\(i)", cordAmount: "B", deliveryDate: "C"))
        }
        XCTAssertEqual(store.items.count, Store.freeLimit)
        let blocked = store.add(FirewoodLogItem(stackLocation: "over", cordAmount: "B", deliveryDate: "C"))
        XCTAssertFalse(blocked)
        XCTAssertEqual(store.items.count, Store.freeLimit)
    }

    func testProBypassesLimit() {
        store.isPro = true
        for i in 0..<(Store.freeLimit + 5) {
            store.add(FirewoodLogItem(stackLocation: "\(i)", cordAmount: "B", deliveryDate: "C"))
        }
        XCTAssertEqual(store.items.count, Store.freeLimit + 5)
    }

    func testDeleteItem() {
        let item = FirewoodLogItem(stackLocation: "A", cordAmount: "B", deliveryDate: "C")
        store.add(item)
        store.delete(item)
        XCTAssertTrue(store.items.isEmpty)
    }

    func testUpdateItem() {
        var item = FirewoodLogItem(stackLocation: "A", cordAmount: "B", deliveryDate: "C")
        store.add(item)
        item.stackLocation = "Updated"
        store.update(item)
        XCTAssertEqual(store.items.first?.stackLocation, "Updated")
    }

    func testCanAddMoreTrueInitially() {
        XCTAssertTrue(store.canAddMore)
    }

    func testDeleteAtOffsets() {
        store.add(FirewoodLogItem(stackLocation: "A", cordAmount: "B", deliveryDate: "C"))
        store.add(FirewoodLogItem(stackLocation: "D", cordAmount: "E", deliveryDate: "F"))
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.items.count, 1)
    }

    func testPersistenceRoundTrip() {
        store.add(FirewoodLogItem(stackLocation: "Persist", cordAmount: "B", deliveryDate: "C"))
        let reloaded = Store()
        XCTAssertTrue(reloaded.items.contains(where: { $0.stackLocation == "Persist" }))
    }
}
