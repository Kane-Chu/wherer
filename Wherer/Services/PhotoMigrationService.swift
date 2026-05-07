import CoreData

struct PhotoMigrationService {
    static func migrateIfNeeded(context: NSManagedObjectContext) {
        let key = "PhotoMigrationToCloudKit_v2_completed"
        guard !UserDefaults.standard.bool(forKey: key) else { return }

        context.performAndWait {
            migrateItemPhotos(context: context)
            migrateLegacyCovers(context: context)
            UserDefaults.standard.set(true, forKey: key)
        }
    }

    private static func migrateItemPhotos(context: NSManagedObjectContext) {
        let request: NSFetchRequest<ItemPhoto> = ItemPhoto.fetchRequest()
        request.predicate = NSPredicate(format: "imageData == nil AND filename != nil AND filename != ''")

        do {
            let photos = try context.fetch(request)
            var migrated = 0
            for photo in photos {
                guard let image = PhotoService.loadPhoto(filename: photo.wrappedFilename) else { continue }
                photo.imageData = try? PhotoService.jpegData(from: image)
                migrated += 1
            }
            if migrated > 0 {
                try context.save()
                print("Migrated \(migrated) photos to Core Data binary storage")
            }
        } catch {
            print("Photo migration failed: \(error)")
        }
    }

    private static func migrateLegacyCovers(context: NSManagedObjectContext) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "photoFilename != nil AND photoFilename != '' AND photos.@count == 0")

        do {
            let items = try context.fetch(request)
            for item in items {
                guard let filename = item.photoFilename,
                      let image = PhotoService.loadPhoto(filename: filename) else { continue }
                let photo = ItemPhoto(context: context)
                photo.id = UUID()
                photo.imageData = try? PhotoService.jpegData(from: image)
                photo.filename = filename
                photo.isCover = true
                photo.createdAt = item.createdAt ?? Date()
                photo.item = item
            }
            if !items.isEmpty {
                try context.save()
                print("Migrated \(items.count) legacy cover photos")
            }
        } catch {
            print("Legacy photo migration failed: \(error)")
        }
    }
}
