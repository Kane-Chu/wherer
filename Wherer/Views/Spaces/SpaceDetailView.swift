import SwiftUI

struct SpaceDetailView: View {
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var spaceStore: SpaceStore
    let space: Space
    @State private var showingAddItem = false
    @State private var editingItem: Item?

    var body: some View {
        let items = itemStore.items(for: space)
        List {
            ForEach(items) { item in
                Button {
                    editingItem = item
                } label: {
                    HStack(spacing: 12) {
                        if let filename = item.coverPhotoFilename,
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
                            Text(item.wrappedLocation)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if !item.wrappedTags.isEmpty {
                                HStack(spacing: 4) {
                                    ForEach(item.wrappedTags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.caption2)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(Color.accentColor.opacity(0.12))
                                            .foregroundColor(.accentColor)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
            .onDelete { indexSet in
                indexSet.forEach { itemStore.deleteItem(items[$0]) }
            }
        }
        .listStyle(.plain)
        .navigationTitle(space.wrappedName)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddItem = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            ItemFormView(space: space)
                .environmentObject(itemStore)
                .environmentObject(spaceStore)
        }
        .sheet(item: $editingItem) { item in
            ItemFormView(space: space, item: item)
                .environmentObject(itemStore)
                .environmentObject(spaceStore)
        }
    }
}
