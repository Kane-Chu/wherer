import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var spaceStore: SpaceStore
    @StateObject private var itemStore: ItemStore

    init(context: NSManagedObjectContext) {
        let store = SpaceStore(context: context)
        _spaceStore = StateObject(wrappedValue: store)
        _itemStore = StateObject(wrappedValue: ItemStore(context: context))
    }

    var body: some View {
        TabView {
            SpaceListView()
                .tabItem {
                    Label("空间", systemImage: "house")
                }
                .environmentObject(spaceStore)
                .environmentObject(itemStore)

            ItemListView()
                .tabItem {
                    Label("物品", systemImage: "cube.box")
                }
                .environmentObject(spaceStore)
                .environmentObject(itemStore)
        }
        .accentColor(AppColors.accent)
    }
}
