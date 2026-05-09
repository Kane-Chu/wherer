import SwiftUI

struct SpaceListView: View {
    @EnvironmentObject var spaceStore: SpaceStore
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingAddSpace = false
    @State private var editingSpace: Space?
    @State private var selectedItemID: ItemIdentifier?
    @State private var searchQuery = ""
    @State private var path = NavigationPath()
    @AppStorage("spaceViewMode") private var viewMode = "grid"

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    SearchBar(text: $searchQuery)

                    HStack {
                        Text(searchQuery.isEmpty ? "我的空间" : "搜索结果")
                            .font(.title3.weight(.bold))
                        Spacer()
                        Button {
                            viewMode = viewMode == "grid" ? "list" : "grid"
                        } label: {
                            Image(systemName: viewMode == "grid" ? "list.bullet" : "square.grid.2x2")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()

                if viewMode == "grid" {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            if searchQuery.isEmpty {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                    ForEach(spaceStore.spaces) { space in
                                        Button {
                                            path.append(space)
                                        } label: {
                                            SpaceCardView(space: space)
                                        }
                                        .buttonStyle(.plain)
                                        .contextMenu {
                                            Button {
                                                editingSpace = space
                                            } label: {
                                                Label("编辑", systemImage: "pencil")
                                            }

                                            Button(role: .destructive) {
                                                spaceStore.deleteSpace(space)
                                            } label: {
                                                Label("删除", systemImage: "trash")
                                            }
                                        }
                                    }
                                }

                                if !itemStore.recentItems.isEmpty {
                                    RecentItemsSection(items: itemStore.recentItems, selectedItemID: $selectedItemID)
                                        .padding(.top, 8)
                                }
                            } else {
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
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                } else {
                    List {
                        if searchQuery.isEmpty {
                            ForEach(spaceStore.spaces) { space in
                                SpaceListRowView(space: space)
                                    .padding(.vertical, 4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .onTapGesture {
                                        path.append(space)
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            spaceStore.deleteSpace(space)
                                        } label: {
                                            Text("删除")
                                        }

                                        Button {
                                            editingSpace = space
                                        } label: {
                                            Text("编辑")
                                        }
                                        .tint(.blue)
                                    }
                                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                            }

                            if !itemStore.recentItems.isEmpty {
                                Section("最近添加") {
                                    ForEach(itemStore.recentItems) { item in
                                        RecentItemRowView(item: item)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .onTapGesture {
                                                selectedItemID = ItemIdentifier(id: item.wrappedId)
                                            }
                                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                                    }
                                }
                            }
                        } else {
                            ForEach(SearchService.filter(items: itemStore.items, query: searchQuery)) { item in
                                SearchResultRowView(item: item)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .onTapGesture {
                                        selectedItemID = ItemIdentifier(id: item.wrappedId)
                                    }
                                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                            }
                        }
                    }
                    .listStyle(.plain)
                    .environment(\.defaultMinListRowHeight, 0)
                }
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
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("addSpaceButton")
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

struct SpaceListRowView: View {
    let space: Space

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: space.wrappedIcon)
                .font(.system(size: 20))
                .frame(width: 48, height: 48)
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(14)

            VStack(alignment: .leading, spacing: 4) {
                Text(space.wrappedName)
                    .font(.body.weight(.medium))
                Text("\(space.itemCount) 件物品")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }

    private var backgroundColor: some View {
        if let preset = space.colorPreset {
            return AnyView(preset.gradient.opacity(0.15))
        } else {
            return AnyView(Color(hex: space.wrappedColorHex).opacity(0.15))
        }
    }

    private var foregroundColor: Color {
        if let preset = space.colorPreset {
            return preset.startColor
        }
        return Color(hex: space.wrappedColorHex)
    }
}

struct SearchResultRowView: View {
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
                Text(item.wrappedLocation)
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
