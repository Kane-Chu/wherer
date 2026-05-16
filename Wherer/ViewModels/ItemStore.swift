import CoreData
import UIKit

@MainActor
class ItemStore: ObservableObject {
    @Published var items: [Item] = []
    @Published var searchQuery: String = ""
    @Published var lastErrorMessage: String?
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchItems()
    }

    func fetchItems() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.createdAt, ascending: false)]
        do {
            items = try context.fetch(request)
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = "物品读取失败，请稍后重试。"
            AppLogger.error("Failed to fetch items: \(error)")
            items = []
        }
    }

    var filteredItems: [Item] {
        SearchService.filter(items: items, query: searchQuery)
    }

    var recentItems: [Item] {
        Array(items.prefix(5))
    }

    func items(for space: Space) -> [Item] {
        filteredItems.filter { $0.wrappedSpace == space }
    }

    func items(for category: Category) -> [Item] {
        filteredItems.filter { $0.wrappedCategory == category }
    }

    func addItem(name: String, location: String, space: Space, category: Category, tags: String, images: [UIImage], coverIndex: Int?) {
        let item = Item(context: context)
        let id = UUID()
        item.id = id
        item.name = name
        item.location = location
        item.space = space
        item.category = category.rawValue
        item.tags = tags
        item.createdAt = Date()
        item.updatedAt = Date()

        syncPhotos(for: item, images: images, coverIndex: coverIndex)

        saveContext()
        fetchItems()
    }

    func updateItem(_ item: Item, name: String, location: String, space: Space, category: Category, tags: String, images: [UIImage], coverIndex: Int?) {
        item.name = name
        item.location = location
        item.space = space
        item.category = category.rawValue
        item.tags = tags
        item.updatedAt = Date()

        // Remove old photos
        if let oldPhotos = item.photos as? Set<ItemPhoto> {
            for photo in oldPhotos {
                context.delete(photo)
            }
        }
        if let oldFilename = item.photoFilename {
            PhotoService.deletePhoto(filename: oldFilename)
            item.photoFilename = nil
        }

        syncPhotos(for: item, images: images, coverIndex: coverIndex)

        saveContext()
        context.refresh(item, mergeChanges: true)
        fetchItems()
    }

    func deleteItem(_ item: Item) {
        if let filename = item.photoFilename {
            PhotoService.deletePhoto(filename: filename)
        }
        context.delete(item)
        saveContext()
        fetchItems()
    }

    private func syncPhotos(for item: Item, images: [UIImage], coverIndex: Int?) {
        let effectiveCover = normalizedCoverIndex(coverIndex, imageCount: images.count)
        for (index, image) in images.enumerated() {
            do {
                let photo = ItemPhoto(context: context)
                photo.id = UUID()
                photo.imageData = try PhotoService.jpegData(from: image)
                photo.filename = "\(photo.wrappedId.uuidString).jpg"
                photo.isCover = (index == effectiveCover)
                photo.createdAt = Date()
                photo.item = item
            } catch {
                lastErrorMessage = "照片保存失败，请重新选择照片。"
                AppLogger.error("Failed to save photo: \(error)")
            }
        }
    }

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

    private func normalizedCoverIndex(_ coverIndex: Int?, imageCount: Int) -> Int? {
        guard imageCount > 0 else { return nil }
        let requested = coverIndex ?? 0
        return min(max(requested, 0), imageCount - 1)
    }
}
