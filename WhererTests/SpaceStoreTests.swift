import XCTest
import CoreData
@testable import Wherer

final class SpaceStoreTests: XCTestCase {
    @MainActor
    func testSeedDefaultSpaces() {
        let controller = PersistenceController(inMemory: true)
        let store = SpaceStore(context: controller.container.viewContext)
        XCTAssertEqual(store.spaces.count, 4)
        XCTAssertTrue(store.spaces.contains { $0.wrappedName == "卧室" })
    }

    @MainActor
    func testAddSpace() {
        let controller = PersistenceController(inMemory: true)
        let store = SpaceStore(context: controller.container.viewContext)
        store.addSpace(name: "车库", icon: "car.fill", colorHex: "#ff0000")
        XCTAssertEqual(store.spaces.count, 5)
        XCTAssertTrue(store.spaces.contains { $0.wrappedName == "车库" })
    }
}
