import SwiftUI

@main
struct WhererApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        UserDefaults.standard.set(["zh-Hans"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(context: persistenceController.container.viewContext)
        }
    }
}
