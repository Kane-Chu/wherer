import SwiftUI

struct RecentItemsSection: View {
    let items: [Item]
    @Binding var selectedItem: Item?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近添加")
                .font(.title3.weight(.bold))
                .padding(.horizontal, 4)

            ForEach(items) { item in
                Button {
                    selectedItem = item
                } label: {
                    HStack(spacing: 12) {
                        if let filename = item.wrappedPhotoFilename,
                           let image = PhotoService.loadPhoto(filename: filename) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 56, height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray5))
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Image(systemName: item.wrappedCategory.icon)
                                        .foregroundColor(.gray)
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
                    }
                    .padding(.vertical, 4)
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
