import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    private static let managedObjectModel: NSManagedObjectModel = {
        if let model = NSManagedObjectModel.mergedModel(from: [Bundle.main]) {
            return model
        }
        return NSManagedObjectModel.mergedModel(from: nil)!
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        if inMemory || Self.isRunningTests {
            let localContainer = NSPersistentContainer(name: "Wherer", managedObjectModel: Self.managedObjectModel)
            if let description = localContainer.persistentStoreDescriptions.first {
                if inMemory {
                    description.url = URL(fileURLWithPath: "/dev/null")
                }
                description.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
                description.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
                description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            }
            localContainer.loadPersistentStores { _, error in
                if let error = error {
                    AppLogger.error("In-memory container failed to load: \(error)")
                }
            }
            container = localContainer
            container.viewContext.automaticallyMergesChangesFromParent = true
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            return
        }

        let cloudContainer = NSPersistentCloudKitContainer(name: "Wherer", managedObjectModel: Self.managedObjectModel)

        if let description = cloudContainer.persistentStoreDescriptions.first {
            description.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
            description.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        }

        var cloudError: Error?
        cloudContainer.loadPersistentStores { _, error in
            if let error = error {
                cloudError = error
                AppLogger.error("CloudKit container failed to load: \(error)")
            }
        }

        if cloudError == nil, !cloudContainer.persistentStoreCoordinator.persistentStores.isEmpty {
            container = cloudContainer
            PhotoMigrationService.migrateIfNeeded(context: container.viewContext)
        } else {
            AppLogger.info("Falling back to local NSPersistentContainer")
            let localContainer = NSPersistentContainer(name: "Wherer", managedObjectModel: Self.managedObjectModel)
            localContainer.loadPersistentStores { _, error in
                if let error = error {
                    AppLogger.error("Local container failed to load: \(error)")
                }
            }
            container = localContainer
            PhotoMigrationService.migrateIfNeeded(context: container.viewContext)
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    private static var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}
