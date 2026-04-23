import SwiftUI

struct SpaceListView: View {
    @EnvironmentObject var spaceStore: SpaceStore
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingAddSpace = false
    @State private var editingSpace: Space?
    @State private var selectedItemID: ItemIdentifier?
    @State private var searchQuery = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SearchBar(text: $searchQuery)
                        .padding(.horizontal, 4)

                    if searchQuery.isEmpty {
                        Text("我的空间")
                            .font(.title3.weight(.bold))
                            .padding(.horizontal, 4)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(spaceStore.spaces) { space in
                                NavigationLink(value: space) {
                                    SpaceCardView(space: space)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button {
                                        editingSpace = space
                                    } label: {
                                        Label("编辑", systemImage: "pencil")
                                    }
                                }
                            }
                        }

                        if !itemStore.recentItems.isEmpty {
                            RecentItemsSection(items: itemStore.recentItems, selectedItemID: $selectedItemID)
                                .padding(.top, 8)
                        }
                    } else {
                        Text("搜索结果")
                            .font(.title3.weight(.bold))
                            .padding(.horizontal, 4)

                        ForEach(SearchService.filter(items: itemStore.items, query: searchQuery)) { item in
                            Button {
                                selectedItemID = ItemIdentifier(id: item.wrappedId)
                            } label: {
                                SearchResultRowView(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("放哪了")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSpace = true }) {
                        ZStack {
                            Circle()
                                .fill(themeManager.effectiveColors.primaryGradient)
                                .frame(width: 36, height: 36)
                            Image(systemName: "plus")
                                .font(.title3.weight(.semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .navigationDestination(for: Space.self) { space in
                SpaceDetailView(space: space)
                    .environmentObject(itemStore)
                    .environmentObject(spaceStore)
            }
            .sheet(isPresented: $showingAddSpace) {
                SpaceFormView()
                    .environmentObject(spaceStore)
            }
            .sheet(item: $editingSpace) { space in
                SpaceFormView(space: space)
                    .environmentObject(spaceStore)
            }
            .sheet(item: $selectedItemID) { wrapper in
                NavigationStack {
                    ItemDetailView(itemID: wrapper.id)
                        .environmentObject(itemStore)
                        .environmentObject(spaceStore)
                }
            }
        }
    }
}

struct SearchResultRowView: View {
    @ObservedObject var item: Item

    var body: some View {
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
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
