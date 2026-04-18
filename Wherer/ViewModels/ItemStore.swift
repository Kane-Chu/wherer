import CoreData
import UIKit

@MainActor
class ItemStore: ObservableObject {
    @Published var items: [Item] = []
    @Published var searchQuery: String = ""
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
        } catch {
            print("Failed to fetch items: \(error)")
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
                PhotoService.deletePhoto(filename: photo.wrappedFilename)
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
        if let photos = item.photos as? Set<ItemPhoto> {
            for photo in photos {
                PhotoService.deletePhoto(filename: photo.wrappedFilename)
            }
        }
        if let filename = item.photoFilename {
            PhotoService.deletePhoto(filename: filename)
        }
        context.delete(item)
        saveContext()
        fetchItems()
    }

    private func syncPhotos(for item: Item, images: [UIImage], coverIndex: Int?) {
        let effectiveCover = coverIndex ?? 0
        for (index, image) in images.enumerated() {
            do {
                let photo = ItemPhoto(context: context)
                photo.id = UUID()
                photo.filename = try PhotoService.savePhoto(image, for: photo.id ?? UUID())
                photo.isCover = (index == effectiveCover)
                photo.createdAt = Date()
                photo.item = item
            } catch {
                print("Failed to save photo: \(error)")
            }
        }
        if let first = images.first, item.photoFilename == nil {
            do {
                item.photoFilename = try PhotoService.savePhoto(first, for: item.wrappedId)
            } catch {
                print("Failed to save legacy cover photo: \(error)")
            }
        }
    }

    private func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
