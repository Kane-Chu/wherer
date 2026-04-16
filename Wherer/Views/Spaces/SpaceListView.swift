import SwiftUI

struct SpaceListView: View {
    @EnvironmentObject var spaceStore: SpaceStore
    @EnvironmentObject var itemStore: ItemStore
    @State private var showingAddSpace = false
    @State private var editingSpace: Space?
    @State private var selectedItem: Item?
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
                            RecentItemsSection(items: itemStore.recentItems, selectedItem: $selectedItem)
                                .padding(.top, 8)
                        }
                    } else {
                        Text("搜索结果")
                            .font(.title3.weight(.bold))
                            .padding(.horizontal, 4)

                        ForEach(SearchService.filter(items: itemStore.items, query: searchQuery)) { item in
                            Button {
                                selectedItem = item
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
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 4)
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
                        Image(systemName: "plus")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(AppColors.primaryGradient))
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
            .sheet(item: $selectedItem) { item in
                NavigationStack {
                    ItemDetailView(item: item)
                        .environmentObject(itemStore)
                        .environmentObject(spaceStore)
                }
            }
        }
    }
}
