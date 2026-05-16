import XCTest
@testable import Wherer

final class PhotoServiceTests: XCTestCase {
    func testJpegDataConversion() throws {
        let image = createTestImage(color: .red)
        let data = try PhotoService.jpegData(from: image)
        XCTAssertFalse(data.isEmpty, "JPEG data should not be empty")
    }

    func testRoundTripConversion() throws {
        let original = createTestImage(color: .blue)
        let data = try PhotoService.jpegData(from: original)
        let restored = PhotoService.image(from: data)
        XCTAssertNotNil(restored, "Should be able to restore image from JPEG data")
    }

    func testImageFromInvalidData() {
        let result = PhotoService.image(from: Data([0, 1, 2, 3]))
        XCTAssertNil(result, "Should return nil for invalid data")
    }

    func testJpegDataDownscalesLargeImages() throws {
        let image = createTestImage(color: .green, size: CGSize(width: 3000, height: 2000))
        let data = try PhotoService.jpegData(from: image)
        let restored = try XCTUnwrap(PhotoService.image(from: data))

        XCTAssertLessThanOrEqual(max(restored.size.width, restored.size.height), 1600)
    }

    private func createTestImage(color: UIColor, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }
}
