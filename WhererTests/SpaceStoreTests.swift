import XCTest
import CoreData
import UIKit
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

    @MainActor
    func testDeleteSpaceCleansUpPhotoFiles() throws {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        let store = SpaceStore(context: context)

        let space = Space(context: context)
        space.id = UUID()
        space.name = "测试空间"
        space.icon = "house"
        space.colorHex = "#ff0000"
        space.createdAt = Date()

        let item = Item(context: context)
        item.id = UUID()
        item.name = "测试物品"
        item.location = "测试位置"
        item.category = Category.electronics.rawValue
        item.createdAt = Date()
        item.updatedAt = Date()
        item.space = space

        let photoFilename = "\(item.id!.uuidString).jpg"
        let photoURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Photos", isDirectory: true)
            .appendingPathComponent(photoFilename)

        let photoDir = photoURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: photoDir.path) {
            try FileManager.default.createDirectory(at: photoDir, withIntermediateDirectories: true)
        }

        let testImage = UIImage(systemName: "photo")!
        let imageData = testImage.jpegData(compressionQuality: 0.85)!
        try imageData.write(to: photoURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: photoURL.path), "测试照片文件应存在")

        let itemPhoto = ItemPhoto(context: context)
        itemPhoto.id = UUID()
        itemPhoto.filename = photoFilename
        itemPhoto.isCover = true
        itemPhoto.createdAt = Date()
        itemPhoto.item = item

        try context.save()
        store.fetchSpaces()

        XCTAssertTrue(store.spaces.contains { $0.wrappedName == "测试空间" })

        let spaceToDelete = store.spaces.first { $0.wrappedName == "测试空间" }!
        store.deleteSpace(spaceToDelete)

        XCTAssertFalse(store.spaces.contains { $0.wrappedName == "测试空间" }, "空间应已被删除")
        XCTAssertFalse(FileManager.default.fileExists(atPath: photoURL.path), "照片文件应被清理")
    }
}
