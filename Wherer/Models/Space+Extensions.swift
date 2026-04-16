import CoreData
import SwiftUI

extension Space {
    var wrappedId: UUID {
        id ?? UUID()
    }

    var wrappedName: String {
        name ?? ""
    }

    var wrappedIcon: String {
        icon ?? "house"
    }

    var wrappedColorHex: String {
        colorHex ?? "#89f7fe"
    }

    var wrappedCreatedAt: Date {
        createdAt ?? Date()
    }

    var wrappedItems: [Item] {
        let set = items as? Set<Item> ?? []
        return set.sorted { $0.wrappedCreatedAt > $1.wrappedCreatedAt }
    }

    var itemCount: Int {
        wrappedItems.count
    }

    var colorPreset: ColorPreset? {
        ColorPreset.allPresets.first { $0.startHex == wrappedColorHex }
    }
}
