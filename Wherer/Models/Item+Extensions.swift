import CoreData
import UIKit

extension Item {
    var wrappedId: UUID {
        id ?? UUID()
    }

    var wrappedName: String {
        name ?? ""
    }

    var wrappedLocation: String {
        location ?? ""
    }

    var wrappedCategory: Category {
        Category(rawValue: category ?? "") ?? .other
    }

    var wrappedTags: [String] {
        guard let tags = tags, !tags.isEmpty else { return [] }
        return tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }

    var wrappedCreatedAt: Date {
        createdAt ?? Date()
    }

    var wrappedUpdatedAt: Date {
        updatedAt ?? Date()
    }

    var wrappedPhotoFilename: String? {
        photoFilename
    }

    var photoList: [ItemPhoto] {
        let set = photos as? Set<ItemPhoto> ?? []
        return set.sorted { $0.wrappedCreatedAt < $1.wrappedCreatedAt }
    }

    var coverPhoto: ItemPhoto? {
        photoList.first { $0.wrappedIsCover } ?? photoList.first
    }

    var coverPhotoFilename: String? {
        coverPhoto?.wrappedFilename ?? photoFilename
    }

    var coverImage: UIImage? {
        if let photo = coverPhoto {
            return photo.image
        }
        if let fn = photoFilename {
            return PhotoService.loadPhoto(filename: fn)
        }
        return nil
    }

    var wrappedSpace: Space? {
        space
    }
}
