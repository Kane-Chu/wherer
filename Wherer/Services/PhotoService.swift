import UIKit

enum PhotoServiceError: Error {
    case invalidImage
    case saveFailed
}

struct PhotoService {
    private static let photosDirectory: URL = {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let photos = documents.appendingPathComponent("Photos", isDirectory: true)
        if !FileManager.default.fileExists(atPath: photos.path) {
            try? FileManager.default.createDirectory(at: photos, withIntermediateDirectories: true)
        }
        return photos
    }()

    static func savePhoto(_ image: UIImage, for itemID: UUID) throws -> String {
        // Normalize image to ensure jpegData succeeds for any source
        let normalized: UIImage
        if image.imageOrientation == .up {
            normalized = image
        } else {
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            image.draw(in: CGRect(origin: .zero, size: image.size))
            normalized = UIGraphicsGetImageFromCurrentImageContext() ?? image
            UIGraphicsEndImageContext()
        }

        guard let data = normalized.jpegData(compressionQuality: 0.85) else {
            throw PhotoServiceError.invalidImage
        }
        let filename = "\(itemID.uuidString).jpg"
        let url = photosDirectory.appendingPathComponent(filename)
        do {
            try data.write(to: url)
            return filename
        } catch {
            throw PhotoServiceError.saveFailed
        }
    }

    static func loadPhoto(filename: String) -> UIImage? {
        let url = photosDirectory.appendingPathComponent(filename)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    static func deletePhoto(filename: String) {
        let url = photosDirectory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }
}
