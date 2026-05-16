import SwiftUI

struct ItemListView: View {
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var spaceStore: SpaceStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var searchQuery = ""
    @State private var selectedItemID: ItemIdentifier?
    @State private var editingItem: Item?
    @State private var showingAddItem = false
    @AppStorage("itemViewMode") private var viewMode = "grid"

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    SearchBar(text: $searchQuery)

                    HStack {
                        Text("物品清单")
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
                        .accessibilityIdentifier("viewToggleButton")
                    }
                }
                .padding()

                let filtered = SearchService.filter(items: itemStore.items, query: searchQuery)

                if viewMode == "grid" {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            if spaceStore.spaces.isEmpty {
                                Text("请先添加一个空间")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.top, 20)
                            }

                            ForEach(Category.allCases) { category in
                                let items = filtered.filter { $0.wrappedCategory == category }
                                if !items.isEmpty {
                                    CategorySection(category: category, items: items, selectedItemID: $selectedItemID)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                } else {
                    List {
                        if spaceStore.spaces.isEmpty {
                            Text("请先添加一个空间")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 20)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                        }

                        ForEach(Category.allCases) { category in
                            let items = filtered.filter { $0.wrappedCategory == category }
                            if !items.isEmpty {
                                Section {
                                    ForEach(items) { item in
                                        SpaceDetailItemRowView(item: item)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .onTapGesture {
                                                selectedItemID = ItemIdentifier(id: item.wrappedId)
                                            }
                                            .swipeActions(edge: .trailing) {
                                                Button(role: .destructive) {
                                                    itemStore.deleteItem(item)
                                                } label: {
                                                    Text("删除")
                                                }

                                                Button {
                                                    editingItem = item
                                                } label: {
                                                    Text("编辑")
                                                }
                                                .tint(.blue)
                                            }
                                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                                    }
                                } header: {
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
                                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .environment(\.defaultMinListRowHeight, 0)
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddItem = true }) {
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
                    .accessibilityIdentifier("addItemButton")
                }
            }
            .sheet(isPresented: $showingAddItem) {
                if let firstSpace = spaceStore.spaces.first {
                    ItemFormView(space: firstSpace)
                        .environmentObject(itemStore)
                        .environmentObject(spaceStore)
                }
            }
            .sheet(item: $editingItem) { item in
                if let space = item.wrappedSpace {
                    ItemFormView(space: space, item: item)
                        .environmentObject(itemStore)
                        .environmentObject(spaceStore)
                }
            }
            .fullScreenCover(item: $selectedItemID) { wrapper in
                NavigationStack {
                    ItemDetailView(itemID: wrapper.id)
                        .environmentObject(itemStore)
                        .environmentObject(spaceStore)
                }
            }
        }
    }
}
