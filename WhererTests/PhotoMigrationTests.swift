import XCTest
import CoreData
import UIKit
@testable import Wherer

final class PhotoMigrationTests: XCTestCase {
    private var controller: PersistenceController!
    private var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        controller = PersistenceController(inMemory: true)
        context = controller.container.viewContext
        UserDefaults.standard.removeObject(forKey: "PhotoMigrationToCloudKit_v2_completed")
    }

    override func tearDown() {
        cleanUpTestPhotos()
        super.tearDown()
    }

    // MARK: - ItemPhoto migration (disk -> imageData)

    func testMigrateItemPhotoFromDiskToImageData() throws {
        // Create an ItemPhoto with a filename on disk but no imageData
        let space = createSpace()
        let item = createItem(space: space)

        let photo = ItemPhoto(context: context)
        photo.id = UUID()
        photo.filename = "\(photo.wrappedId.uuidString).jpg"
        photo.isCover = true
        photo.createdAt = Date()
        photo.item = item
        try context.save()

        // Write a real JPEG to disk
        let testImage = createTestImage(color: .green)
        let jpegData = testImage.jpegData(compressionQuality: 0.85)!
        let photoDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Photos", isDirectory: true)
        try? FileManager.default.createDirectory(at: photoDir, withIntermediateDirectories: true)
        let photoURL = photoDir.appendingPathComponent(photo.filename!)
        try jpegData.write(to: photoURL)

        // Run migration
        PhotoMigrationService.migrateIfNeeded(context: context)

        // Verify imageData was populated
        let request: NSFetchRequest<ItemPhoto> = ItemPhoto.fetchRequest()
        let results = try context.fetch(request)
        XCTAssertEqual(results.count, 1)
        XCTAssertNotNil(results.first?.imageData, "imageData should be populated after migration")
    }

    func testMigrationRunsOnlyOnce() throws {
        let space = createSpace()
        let item = createItem(space: space)

        let photo = ItemPhoto(context: context)
        photo.id = UUID()
        photo.filename = "\(photo.wrappedId.uuidString).jpg"
        photo.isCover = true
        photo.createdAt = Date()
        photo.item = item
        try context.save()

        PhotoMigrationService.migrateIfNeeded(context: context)

        // Mark as completed, second call should be a no-op
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "PhotoMigrationToCloudKit_v2_completed"))

        // Create another photo that should NOT be migrated
        let photo2 = ItemPhoto(context: context)
        photo2.id = UUID()
        photo2.filename = "unmigrated.jpg"
        photo2.createdAt = Date()
        photo2.item = item
        try context.save()

        PhotoMigrationService.migrateIfNeeded(context: context)

        // photo2 should still have nil imageData
        XCTAssertNil(photo2.imageData, "Second migration run should be skipped")
    }

    // MARK: - Legacy cover photo migration

    func testMigrateLegacyCoverPhoto() throws {
        let space = createSpace()
        let item = createItem(space: space)

        let filename = "\(item.wrappedId.uuidString).jpg"
        item.photoFilename = filename
        try context.save()

        // Write photo to disk
        let testImage = createTestImage(color: .orange)
        let jpegData = testImage.jpegData(compressionQuality: 0.85)!
        let photoDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Photos", isDirectory: true)
        try? FileManager.default.createDirectory(at: photoDir, withIntermediateDirectories: true)
        try jpegData.write(to: photoDir.appendingPathComponent(filename))

        PhotoMigrationService.migrateIfNeeded(context: context)

        // Should have created an ItemPhoto with imageData
        let photoList = item.photoList
        XCTAssertFalse(photoList.isEmpty, "Should create ItemPhoto from legacy photoFilename")
        XCTAssertNotNil(photoList.first?.imageData, "Created ItemPhoto should have imageData")
        XCTAssertTrue(photoList.first?.wrappedIsCover == true, "Migrated photo should be cover")
    }

    // MARK: - ItemPhoto.image property

    func testItemPhotoImageFromImageData() throws {
        let photo = ItemPhoto(context: context)
        photo.id = UUID()
        let testImage = createTestImage(color: .red)
        photo.imageData = try PhotoService.jpegData(from: testImage)
        photo.filename = "test.jpg"
        photo.createdAt = Date()

        XCTAssertNotNil(photo.image, "Should load image from imageData")
    }

    func testItemPhotoImageFallbackToDisk() throws {
        let filename = "fallback_test.jpg"
        let testImage = createTestImage(color: .purple)
        let jpegData = testImage.jpegData(compressionQuality: 0.85)!
        let photoDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Photos", isDirectory: true)
        try? FileManager.default.createDirectory(at: photoDir, withIntermediateDirectories: true)
        try jpegData.write(to: photoDir.appendingPathComponent(filename))

        let photo = ItemPhoto(context: context)
        photo.id = UUID()
        photo.filename = filename
        photo.createdAt = Date()
        // No imageData set

        XCTAssertNotNil(photo.image, "Should fallback to loading from disk filename")
    }

    // MARK: - Item.coverImage property

    func testItemCoverImageFromPhotoList() throws {
        let space = createSpace()
        let item = createItem(space: space)

        let photo = ItemPhoto(context: context)
        photo.id = UUID()
        photo.filename = "test.jpg"
        photo.isCover = true
        photo.createdAt = Date()
        let testImage = createTestImage(color: .cyan)
        photo.imageData = try PhotoService.jpegData(from: testImage)
        photo.item = item
        try context.save()

        XCTAssertNotNil(item.coverImage, "Should get cover image from photo list")
    }

    func testItemCoverImageFromLegacyFilename() throws {
        let space = createSpace()
        let item = createItem(space: space)

        let filename = "\(item.wrappedId.uuidString).jpg"
        item.photoFilename = filename
        try context.save()

        let testImage = createTestImage(color: .magenta)
        let jpegData = testImage.jpegData(compressionQuality: 0.85)!
        let photoDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Photos", isDirectory: true)
        try? FileManager.default.createDirectory(at: photoDir, withIntermediateDirectories: true)
        try jpegData.write(to: photoDir.appendingPathComponent(filename))

        XCTAssertNotNil(item.coverImage, "Should fallback to legacy photoFilename")
    }

    func testItemCoverImageNilWhenNoPhotos() {
        let space = createSpace()
        let item = createItem(space: space)

        XCTAssertNil(item.coverImage, "Should return nil when no photos exist")
    }

    // MARK: - Helpers

    private func createSpace() -> Space {
        let space = Space(context: context)
        space.id = UUID()
        space.name = "测试空间"
        space.icon = "house"
        space.colorHex = "#ff0000"
        space.createdAt = Date()
        return space
    }

    private func createItem(space: Space) -> Item {
        let item = Item(context: context)
        item.id = UUID()
        item.name = "测试物品"
        item.location = "测试位置"
        item.category = Category.electronics.rawValue
        item.createdAt = Date()
        item.updatedAt = Date()
        item.space = space
        return item
    }

    private func createTestImage(color: UIColor) -> UIImage {
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }

    private func cleanUpTestPhotos() {
        let photoDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Photos", isDirectory: true)
        try? FileManager.default.removeItem(at: photoDir)
    }
}
