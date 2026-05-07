import Foundation

struct SearchService {
    static func filter(items: [Item], query: String) -> [Item] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return items }
        return items.filter { item in
            item.wrappedName.localizedCaseInsensitiveContains(trimmed)
            || item.wrappedLocation.localizedCaseInsensitiveContains(trimmed)
            || item.wrappedTags.contains(where: { $0.localizedCaseInsensitiveContains(trimmed) })
            || item.wrappedSpace?.wrappedName.localizedCaseInsensitiveContains(trimmed) ?? false
        }
    }
}
