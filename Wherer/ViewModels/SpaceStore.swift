import CoreData
import SwiftUI

@MainActor
class SpaceStore: ObservableObject {
    @Published var spaces: [Space] = []
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchSpaces()
        seedDefaultSpacesIfNeeded()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleContextSave),
            name: NSManagedObjectContext.didSaveObjectsNotification,
            object: context
        )
    }

    @objc private func handleContextSave() {
        fetchSpaces()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSManagedObjectContext.didSaveObjectsNotification, object: context)
    }

    func fetchSpaces() {
        let request: NSFetchRequest<Space> = Space.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Space.createdAt, ascending: true)]
        do {
            spaces = try context.fetch(request)
        } catch {
            print("Failed to fetch spaces: \(error)")
            spaces = []
        }
    }

    func addSpace(name: String, icon: String, colorHex: String) {
        let space = Space(context: context)
        space.id = UUID()
        space.name = name
        space.icon = icon
        space.colorHex = colorHex
        space.createdAt = Date()
        saveContext()
        fetchSpaces()
    }

    func updateSpace(_ space: Space, name: String, icon: String, colorHex: String) {
        space.name = name
        space.icon = icon
        space.colorHex = colorHex
        saveContext()
        fetchSpaces()
    }

    func deleteSpace(_ space: Space) {
        if let items = space.items as? Set<Item> {
            for item in items {
                if let filename = item.photoFilename {
                    PhotoService.deletePhoto(filename: filename)
                }
            }
        }
        context.delete(space)
        saveContext()
        fetchSpaces()
    }

    private func seedDefaultSpacesIfNeeded() {
        guard spaces.isEmpty else { return }
        let defaults = [
            ("卧室", "bed.double.fill", ColorPreset.allPresets[0].startHex),
            ("书房", "book.fill", ColorPreset.allPresets[1].startHex),
            ("客厅", "sofa.fill", ColorPreset.allPresets[2].startHex),
            ("储物间", "archivebox.fill", ColorPreset.allPresets[3].startHex)
        ]
        var createdSpaces: [Space] = []
        for (name, icon, color) in defaults {
            let space = Space(context: context)
            space.id = UUID()
            space.name = name
            space.icon = icon
            space.colorHex = color
            space.createdAt = Date()
            createdSpaces.append(space)
        }
        saveContext()
        fetchSpaces()

        #if targetEnvironment(simulator)
        seedSampleItems(spaces: createdSpaces)
        #endif
    }

    #if targetEnvironment(simulator)
    private func seedSampleItems(spaces: [Space]) {
        let sampleItems: [(String, String, Space, Category, String)] = [
            ("枕头", "床头柜上", spaces[0], .other, "睡眠,舒适"),
            ("台灯", "书桌角落", spaces[0], .other, "照明"),
            ("MacBook", "桌面上", spaces[1], .electronics, "工作,苹果"),
            ("耳机", "抽屉里", spaces[1], .electronics, "音频"),
            ("遥控器", "茶几上", spaces[2], .electronics, "电视"),
            ("抱枕", "沙发上", spaces[2], .other, "装饰"),
            ("行李箱", "角落", spaces[3], .other, "出行"),
            ("工具箱", "架子上", spaces[3], .other, "维修"),
        ]
        for (name, location, space, category, tags) in sampleItems {
            let item = Item(context: context)
            item.id = UUID()
            item.name = name
            item.location = location
            item.space = space
            item.category = category.rawValue
            item.tags = tags
            item.createdAt = Date()
            item.updatedAt = Date()
        }
        saveContext()
    }
    #endif

    private func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
