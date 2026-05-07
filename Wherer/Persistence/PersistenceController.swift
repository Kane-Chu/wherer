import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        let cloudContainer = NSPersistentCloudKitContainer(name: "Wherer")
        if inMemory {
            if let description = cloudContainer.persistentStoreDescriptions.first {
                description.url = URL(fileURLWithPath: "/dev/null")
            }
        }

        if !inMemory, let description = cloudContainer.persistentStoreDescriptions.first {
            description.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
            description.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        }

        var cloudError: Error?
        cloudContainer.loadPersistentStores { _, error in
            if let error = error {
                cloudError = error
                print("CloudKit container failed to load: \(error)")
            }
        }

        if cloudError == nil, !cloudContainer.persistentStoreCoordinator.persistentStores.isEmpty {
            container = cloudContainer
            if !inMemory {
                PhotoMigrationService.migrateIfNeeded(context: container.viewContext)
            }
        } else {
            print("Falling back to local NSPersistentContainer")
            let localContainer = NSPersistentContainer(name: "Wherer")
            if inMemory {
                if let description = localContainer.persistentStoreDescriptions.first {
                    description.url = URL(fileURLWithPath: "/dev/null")
                }
            }
            localContainer.loadPersistentStores { _, error in
                if let error = error {
                    print("Local container failed to load: \(error)")
                }
            }
            container = localContainer
            if !inMemory {
                PhotoMigrationService.migrateIfNeeded(context: container.viewContext)
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
