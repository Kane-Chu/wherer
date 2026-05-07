import Foundation

enum AppearanceMode: String, CaseIterable {
    case auto = "auto"
    case light = "light"
    case dark = "dark"

    var displayName: String {
        switch self {
        case .auto: return "自动"
        case .light: return "浅色"
        case .dark: return "深色"
        }
    }
}
