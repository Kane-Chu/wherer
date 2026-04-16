import CoreData

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
}
