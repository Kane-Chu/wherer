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
        context.delete(space)
        saveContext()
        fetchSpaces()
    }

    private func seedDefaultSpacesIfNeeded() {
        guard spaces.isEmpty else { return }
        let defaults = [
            ("卧室", "bed.double.fill", "#ffeaa7"),
            ("书房", "book.fill", "#a8edea"),
            ("客厅", "sofa.fill", "#d299c2"),
            ("储物间", "archivebox.fill", "#89f7fe")
        ]
        for (name, icon, color) in defaults {
            let space = Space(context: context)
            space.id = UUID()
            space.name = name
            space.icon = icon
            space.colorHex = color
            space.createdAt = Date()
        }
        saveContext()
        fetchSpaces()
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
