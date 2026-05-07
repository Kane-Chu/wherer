import SwiftUI

struct RecentItemsSection: View {
    let items: [Item]
    @Binding var selectedItemID: ItemIdentifier?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近添加")
                .font(.title3.weight(.bold))
                .padding(.horizontal, 4)

            ForEach(items) { item in
                Button {
                    selectedItemID = ItemIdentifier(id: item.wrappedId)
                } label: {
                    RecentItemRowView(item: item)
                }
                .buttonStyle(.plain)

                if item.id != items.last?.id {
                    Divider()
                        .padding(.leading, 68)
                }
            }
        }
    }
}

struct RecentItemRowView: View {
    @ObservedObject var item: Item

    var body: some View {
        HStack(spacing: 12) {
            if let image = item.coverImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: item.wrappedCategory.icon)
                            .foregroundColor(.secondary)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.wrappedName)
                    .font(.body.weight(.medium))
                Text("\(item.wrappedSpace?.wrappedName ?? "") · \(item.wrappedCreatedAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
