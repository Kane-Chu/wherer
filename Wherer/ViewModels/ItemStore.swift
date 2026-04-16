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

    func addItem(name: String, location: String, space: Space, category: Category, tags: String, image: UIImage?) {
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

        if let image = image {
            do {
                let filename = try PhotoService.savePhoto(image, for: id)
                item.photoFilename = filename
            } catch {
                print("Failed to save photo: \(error)")
            }
        }

        saveContext()
        fetchItems()
    }

    func updateItem(_ item: Item, name: String, location: String, space: Space, category: Category, tags: String, image: UIImage?) {
        item.name = name
        item.location = location
        item.space = space
        item.category = category.rawValue
        item.tags = tags
        item.updatedAt = Date()

        if let image = image {
            if let oldFilename = item.photoFilename {
                PhotoService.deletePhoto(filename: oldFilename)
            }
            do {
                let filename = try PhotoService.savePhoto(image, for: item.wrappedId)
                item.photoFilename = filename
            } catch {
                print("Failed to save photo: \(error)")
            }
        }

        saveContext()
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

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
