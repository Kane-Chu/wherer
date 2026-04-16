import SwiftUI

struct ItemListView: View {
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var spaceStore: SpaceStore
    @State private var searchQuery = ""
    @State private var selectedItem: Item?
    @State private var showingAddItem = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SearchBar(text: $searchQuery)
                        .padding(.horizontal, 4)

                    let filtered = SearchService.filter(items: itemStore.items, query: searchQuery)

                    ForEach(Category.allCases) { category in
                        let items = filtered.filter { $0.wrappedCategory == category }
                        if !items.isEmpty {
                            CategorySection(category: category, items: items, selectedItem: $selectedItem)
                                .padding(.horizontal, 4)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("全部物品")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddItem = true }) {
                        Image(systemName: "plus")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "#667eea"), Color(hex: "#764ba2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                if let firstSpace = spaceStore.spaces.first {
                    ItemFormView(space: firstSpace)
                        .environmentObject(itemStore)
                        .environmentObject(spaceStore)
                }
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
