import CoreData
import UIKit

extension ItemPhoto {
    var wrappedId: UUID {
        id ?? UUID()
    }

    var wrappedFilename: String {
        filename ?? ""
    }

    var wrappedIsCover: Bool {
        isCover
    }

    var wrappedCreatedAt: Date {
        createdAt ?? Date()
    }

    var image: UIImage? {
        if let data = imageData {
            return PhotoService.image(from: data)
        }
        if !wrappedFilename.isEmpty {
            return PhotoService.loadPhoto(filename: wrappedFilename)
        }
        return nil
    }
}
