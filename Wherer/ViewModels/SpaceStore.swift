import CoreData
import SwiftUI

@MainActor
class SpaceStore: ObservableObject {
    @Published var spaces: [Space] = []
    @Published var lastErrorMessage: String?
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context

        if ProcessInfo.processInfo.arguments.contains("-resetData") {
            resetAllData()
        }

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

    private func resetAllData() {
        let entities = ["Space", "Item", "ItemPhoto"]
        for entityName in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            batchDelete.resultType = .resultTypeObjectIDs
            do {
                let result = try context.execute(batchDelete) as? NSBatchDeleteResult
                if let objectIDs = result?.result as? [NSManagedObjectID] {
                    let changes = [NSDeletedObjectsKey: objectIDs]
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
                }
            } catch {
                lastErrorMessage = "测试数据重置失败。"
                AppLogger.error("Failed to reset \(entityName): \(error)")
            }
        }
    }

    func fetchSpaces() {
        let request: NSFetchRequest<Space> = Space.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Space.createdAt, ascending: true)]
        do {
            spaces = try context.fetch(request)
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = "空间读取失败，请稍后重试。"
            AppLogger.error("Failed to fetch spaces: \(error)")
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

        let defaults: [(String, String, String)]
        let items: [(String, String, Int, Category, String)]

        if ProcessInfo.processInfo.arguments.contains("-screenshotData") {
            defaults = [
                ("卧室", "bed.double.fill", ColorPreset.allPresets[0].startHex),
                ("客厅", "sofa.fill", ColorPreset.allPresets[2].startHex),
                ("厨房", "fork.knife", ColorPreset.allPresets[6].startHex)
            ]
            items = [
                ("电脑", "客厅茶几下面", 1, .electronics, "工作,苹果"),
                ("灯泡", "客厅电视柜旁", 1, .electronics, "照明,智能"),
                ("玩具", "客厅沙发角落", 1, .other, "儿童,娱乐"),
                ("感冒药", "卧室衣柜上层", 0, .medicine, "药品,健康"),
                ("书籍", "卧室书桌抽屉", 0, .other, "阅读,学习"),
                ("围巾", "卧室衣柜下层", 0, .clothing, "保暖,冬季"),
                ("衣服", "卧室衣柜挂架", 0, .clothing, "日常,穿搭"),
                ("鞋子", "卧室床底鞋盒", 0, .clothing, "出行,运动"),
                ("订书机", "厨房储物柜", 2, .other, "办公,文具")
            ]
        } else {
            defaults = [
                ("卧室", "bed.double.fill", ColorPreset.allPresets[0].startHex),
                ("书房", "book.fill", ColorPreset.allPresets[1].startHex),
                ("客厅", "sofa.fill", ColorPreset.allPresets[2].startHex),
                ("储物间", "archivebox.fill", ColorPreset.allPresets[3].startHex)
            ]
            items = [
                ("枕头", "床头柜上", 0, .other, "睡眠,舒适"),
                ("台灯", "书桌角落", 0, .other, "照明"),
                ("MacBook", "桌面上", 1, .electronics, "工作,苹果"),
                ("耳机", "抽屉里", 1, .electronics, "音频"),
                ("遥控器", "茶几上", 2, .electronics, "电视"),
                ("抱枕", "沙发上", 2, .other, "装饰"),
                ("行李箱", "角落", 3, .other, "出行"),
                ("工具箱", "架子上", 3, .other, "维修"),
            ]
        }

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
        seedItems(spaces: createdSpaces, items: items)
        #endif
    }

    #if targetEnvironment(simulator)
    private func seedItems(spaces: [Space], items: [(String, String, Int, Category, String)]) {
        for (name, location, spaceIndex, category, tags) in items {
            guard spaceIndex < spaces.count else { continue }
            let item = Item(context: context)
            item.id = UUID()
            item.name = name
            item.location = location
            item.space = spaces[spaceIndex]
            item.category = category.rawValue
            item.tags = tags
            item.createdAt = Date()
            item.updatedAt = Date()

            // 为截图数据添加图片
            // 从 Asset Catalog 加载图片
            if let image = UIImage(named: name), let data = image.jpegData(compressionQuality: 0.9) {
                let photo = ItemPhoto(context: context)
                photo.id = UUID()
                photo.imageData = data
                photo.filename = "\(photo.wrappedId.uuidString).jpg"
                photo.isCover = true
                photo.createdAt = Date()
                photo.item = item
            }
        }
        saveContext()
    }

    #endif

    private func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = "保存失败，请稍后重试。"
            AppLogger.error("Failed to save context: \(error)")
        }
    }
}
