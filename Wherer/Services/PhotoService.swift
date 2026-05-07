import UIKit

enum PhotoServiceError: Error {
    case invalidImage
}

struct PhotoService {
    static func jpegData(from image: UIImage) throws -> Data {
        let normalized = normalizeImage(image)
        guard let data = normalized.jpegData(compressionQuality: 0.85) else {
            throw PhotoServiceError.invalidImage
        }
        return data
    }

    static func image(from data: Data) -> UIImage? {
        UIImage(data: data)
    }

    // MARK: - Legacy (migration only)

    private static let photosDirectory: URL = {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent("Photos", isDirectory: true)
    }()

    static func loadPhoto(filename: String) -> UIImage? {
        let url = photosDirectory.appendingPathComponent(filename)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    static func deletePhoto(filename: String) {
        let url = photosDirectory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }

    private static func normalizeImage(_ image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else { return image }
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        return normalized
    }
}
