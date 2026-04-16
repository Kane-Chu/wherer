import SwiftUI

struct CategorySection: View {
    let category: Category
    let items: [Item]
    @Binding var selectedItem: Item?

    private var categoryColor: Color {
        switch category {
        case .clothing: return Color(hex: "#ff7675")
        case .document: return Color(hex: "#74b9ff")
        case .medicine: return Color(hex: "#00b894")
        case .electronics: return Color(hex: "#fdcb6e")
        case .other: return Color(hex: "#b2bec3")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Circle()
                    .fill(categoryColor)
                    .frame(width: 8, height: 8)
                Text(category.rawValue)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(items.count) 件")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(items) { item in
                    Button {
                        selectedItem = item
                    } label: {
                        ItemMiniCardView(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
