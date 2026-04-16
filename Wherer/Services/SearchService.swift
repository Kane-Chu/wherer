import Foundation

struct SearchService {
    static func filter(items: [Item], query: String) -> [Item] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return items }
        let lowercased = trimmed.lowercased()
        return items.filter { item in
            item.wrappedName.localizedCaseInsensitiveContains(lowercased)
            || item.wrappedLocation.localizedCaseInsensitiveContains(lowercased)
            || item.wrappedTags.contains(where: { $0.localizedCaseInsensitiveContains(lowercased) })
            || item.wrappedSpace?.wrappedName.localizedCaseInsensitiveContains(lowercased) ?? false
        }
    }
}
