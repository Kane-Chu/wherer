import XCTest
import CoreData
@testable import Wherer

final class SearchServiceTests: XCTestCase {
    private var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        let controller = PersistenceController(inMemory: true)
        context = controller.container.viewContext
    }

    private func makeItem(name: String, location: String, tags: String = "", spaceName: String = "") -> Item {
        let item = Item(context: context)
        item.id = UUID()
        item.name = name
        item.location = location
        item.category = Category.other.rawValue
        item.tags = tags
        item.createdAt = Date()
        item.updatedAt = Date()
        if !spaceName.isEmpty {
            let space = Space(context: context)
            space.id = UUID()
            space.name = spaceName
            space.icon = "house"
            space.colorHex = "#ff0000"
            space.createdAt = Date()
            item.space = space
        }
        return item
    }

    func testFilterByName() {
        let item = makeItem(name: "相机", location: "书房")

        let results = SearchService.filter(items: [item], query: "相")
        XCTAssertEqual(results.count, 1)

        let empty = SearchService.filter(items: [item], query: "手机")
        XCTAssertEqual(empty.count, 0)
    }

    func testFilterByLocation() {
        let item = makeItem(name: "耳机", location: "抽屉里")

        let results = SearchService.filter(items: [item], query: "抽屉")
        XCTAssertEqual(results.count, 1)
    }

    func testFilterByTags() {
        let item = makeItem(name: "行李箱", location: "角落", tags: "出行,旅行")

        let results = SearchService.filter(items: [item], query: "旅行")
        XCTAssertEqual(results.count, 1)
    }

    func testFilterBySpaceName() {
        let item = makeItem(name: "枕头", location: "床头柜", spaceName: "卧室")

        let results = SearchService.filter(items: [item], query: "卧室")
        XCTAssertEqual(results.count, 1)
    }

    func testFilterEmptyQueryReturnsAll() {
        let item1 = makeItem(name: "A", location: "X")
        let item2 = makeItem(name: "B", location: "Y")

        let results = SearchService.filter(items: [item1, item2], query: "")
        XCTAssertEqual(results.count, 2)
    }

    func testFilterWhitespaceQueryReturnsAll() {
        let item1 = makeItem(name: "A", location: "X")
        let item2 = makeItem(name: "B", location: "Y")

        let results = SearchService.filter(items: [item1, item2], query: "   ")
        XCTAssertEqual(results.count, 2)
    }

    func testFilterCaseInsensitive() {
        let item = makeItem(name: "MacBook Pro", location: "桌面")

        let lower = SearchService.filter(items: [item], query: "macbook")
        let upper = SearchService.filter(items: [item], query: "MACBOOK")
        XCTAssertEqual(lower.count, 1)
        XCTAssertEqual(upper.count, 1)
    }

    func testFilterResultConsistencyAcrossCalls() {
        let item1 = makeItem(name: "MacBook", location: "书房", tags: "苹果")
        let item2 = makeItem(name: "iPad", location: "卧室", tags: "平板")
        let items = [item1, item2]

        let r1 = SearchService.filter(items: items, query: "书房")
        let r2 = SearchService.filter(items: items, query: "书房")
        XCTAssertEqual(r1.count, r2.count)
        XCTAssertEqual(Set(r1.map { $0.wrappedName }), Set(r2.map { $0.wrappedName }))
    }
}
