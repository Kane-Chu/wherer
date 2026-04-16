import XCTest
@testable import Wherer

final class ModelTests: XCTestCase {
    func testCategoryIcon() {
        XCTAssertEqual(Category.electronics.icon, "cpu")
    }

    func testColorPresetCount() {
        XCTAssertEqual(ColorPreset.allPresets.count, 8)
    }
}
