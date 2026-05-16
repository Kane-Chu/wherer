import XCTest
import CoreData
import UIKit
@testable import Wherer

final class ItemStorePhotoTests: XCTestCase {
    private var controller: PersistenceController!
    private var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        controller = PersistenceController(inMemory: true)
        context = controller.container.viewContext
    }

    // MARK: - syncPhotos writes imageData

    @MainActor
    func testAddItemStoresPhotoInImageData() throws {
        let spaceStore = SpaceStore(context: context)
        let itemStore = ItemStore(context: context)
        let space = spaceStore.spaces.first!

        let testImage = createTestImage()
        itemStore.addItem(
            name: "测试",
            location: "位置",
            space: space,
            category: .electronics,
            tags: "",
            images: [testImage],
            coverIndex: 0
        )

        let item = itemStore.items.first!
        let photos = item.photoList
        XCTAssertEqual(photos.count, 1)

        let photo = photos.first!
        XCTAssertNotNil(photo.imageData, "Photo should have imageData stored in Core Data")
        XCTAssertFalse(photo.imageData!.isEmpty, "imageData should not be empty")
    }

    @MainActor
    func testAddItemWithMultiplePhotos() throws {
        let spaceStore = SpaceStore(context: context)
        let itemStore = ItemStore(context: context)
        let space = spaceStore.spaces.first!

        let images = [createTestImage(), createTestImage(), createTestImage()]
        itemStore.addItem(
            name: "多图测试",
            location: "位置",
            space: space,
            category: .other,
            tags: "",
            images: images,
            coverIndex: 1
        )

        let item = itemStore.items.first!
        let photos = item.photoList
        XCTAssertEqual(photos.count, 3)

        let coverPhoto = photos.first { $0.wrappedIsCover }
        XCTAssertNotNil(coverPhoto, "Should have a cover photo")

        // Verify all photos have imageData
        for photo in photos {
            XCTAssertNotNil(photo.imageData, "All photos should have imageData")
        }
    }

    @MainActor
    func testAddItemClampsOutOfRangeCoverIndex() throws {
        let spaceStore = SpaceStore(context: context)
        let itemStore = ItemStore(context: context)
        let space = spaceStore.spaces.first!

        itemStore.addItem(
            name: "封面越界测试",
            location: "位置",
            space: space,
            category: .other,
            tags: "",
            images: [createTestImage(), createTestImage()],
            coverIndex: 99
        )

        let item = itemStore.items.first { $0.wrappedName == "封面越界测试" }!
        let covers = item.photoList.filter { $0.wrappedIsCover }
        XCTAssertEqual(covers.count, 1, "Exactly one photo should be selected as cover")
        XCTAssertEqual(covers.first, item.photoList.last, "Out-of-range cover index should use the last photo")
    }

    // MARK: - deleteItem does not delete disk files for ItemPhoto

    @MainActor
    func testDeleteItemDoesNotRequireDiskFile() throws {
        let spaceStore = SpaceStore(context: context)
        let itemStore = ItemStore(context: context)
        let space = spaceStore.spaces.first!

        let testImage = createTestImage()
        itemStore.addItem(
            name: "删除测试",
            location: "位置",
            space: space,
            category: .electronics,
            tags: "",
            images: [testImage],
            coverIndex: 0
        )

        let item = itemStore.items.first { $0.wrappedName == "删除测试" }!
        let countBefore = itemStore.items.count

        // Should not crash or throw when deleting (no disk files to clean up for ItemPhoto)
        itemStore.deleteItem(item)
        XCTAssertEqual(itemStore.items.count, countBefore - 1, "Item count should decrease by 1")
        XCTAssertFalse(itemStore.items.contains { $0.wrappedName == "删除测试" }, "Deleted item should be gone")
    }

    @MainActor
    func testDeleteItemCascadesStoredPhotos() throws {
        let spaceStore = SpaceStore(context: context)
        let itemStore = ItemStore(context: context)
        let space = spaceStore.spaces.first!

        itemStore.addItem(
            name: "照片级联删除测试",
            location: "位置",
            space: space,
            category: .electronics,
            tags: "",
            images: [createTestImage(), createTestImage()],
            coverIndex: 0
        )

        let item = itemStore.items.first { $0.wrappedName == "照片级联删除测试" }!
        XCTAssertEqual(try countPhotos(), 2)

        itemStore.deleteItem(item)

        XCTAssertEqual(try countPhotos(), 0, "Deleting an item should delete its stored ItemPhoto children")
    }

    // MARK: - updateItem replaces photos with imageData

    @MainActor
    func testUpdateItemReplacesPhotos() throws {
        let spaceStore = SpaceStore(context: context)
        let itemStore = ItemStore(context: context)
        let space = spaceStore.spaces.first!

        itemStore.addItem(
            name: "更新测试",
            location: "位置",
            space: space,
            category: .electronics,
            tags: "",
            images: [createTestImage()],
            coverIndex: 0
        )

        let item = itemStore.items.first!
        XCTAssertEqual(item.photoList.count, 1)

        // Update with 2 new photos
        itemStore.updateItem(
            item,
            name: "已更新",
            location: "新位置",
            space: space,
            category: .other,
            tags: "标签",
            images: [createTestImage(), createTestImage()],
            coverIndex: 0
        )

        XCTAssertEqual(item.photoList.count, 2, "Should have 2 new photos")
        for photo in item.photoList {
            XCTAssertNotNil(photo.imageData, "Updated photos should have imageData")
        }
    }

    // MARK: - Helpers

    private func createTestImage() -> UIImage {
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor.blue.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }

    private func countPhotos() throws -> Int {
        let request: NSFetchRequest<ItemPhoto> = ItemPhoto.fetchRequest()
        return try context.count(for: request)
    }
}
