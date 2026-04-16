import CoreData

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

    var wrappedSpace: Space? {
        space
    }
}
