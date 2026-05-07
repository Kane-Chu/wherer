import SwiftUI

@main
struct WhererApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var themeManager = ThemeManager()

    init() {
        UserDefaults.standard.set(["zh-Hans"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(context: persistenceController.container.viewContext)
                .environmentObject(themeManager)
        }
    }
}
