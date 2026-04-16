import XCTest
@testable import Wherer

final class SearchServiceTests: XCTestCase {
    func testFilterByName() {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        let item = Item(context: context)
        item.id = UUID()
        item.name = "相机"
        item.location = "书房"
        item.category = "数码"
        item.createdAt = Date()
        item.updatedAt = Date()

        let results = SearchService.filter(items: [item], query: "相")
        XCTAssertEqual(results.count, 1)

        let empty = SearchService.filter(items: [item], query: "手机")
        XCTAssertEqual(empty.count, 0)
    }
}
