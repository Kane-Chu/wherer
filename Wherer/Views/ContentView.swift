import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var spaceStore: SpaceStore
    @StateObject private var itemStore: ItemStore
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme

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

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape.fill")
                }
                .environmentObject(themeManager)
        }
        .accentColor(themeManager.effectiveColors.accent)
        .preferredColorScheme(themeManager.effectiveColorScheme)
        .onChange(of: colorScheme) { newScheme in
            themeManager.systemColorScheme = newScheme
        }
    }
}
