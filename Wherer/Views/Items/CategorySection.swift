import SwiftUI

struct CategorySection: View {
    let category: Category
    let items: [Item]
    @Binding var selectedItem: Item?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Circle()
                    .fill(category.color)
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
