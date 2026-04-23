import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var currentTheme: Theme
    @Published var appearanceMode: AppearanceMode

    private var cancellables = Set<AnyCancellable>()

    static let allThemes = Theme.allThemes

    var effectiveColors: ThemeColors {
        let isDark: Bool
        switch appearanceMode {
        case .auto:
            isDark = UITraitCollection.current.userInterfaceStyle == .dark
        case .light:
            isDark = false
        case .dark:
            isDark = true
        }
        return isDark ? currentTheme.dark : currentTheme.light
    }

    var effectiveColorScheme: ColorScheme? {
        switch appearanceMode {
        case .auto: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    init() {
        let savedThemeId = UserDefaults.standard.string(forKey: "selectedThemeId")
        currentTheme = Theme.allThemes.first { $0.id == savedThemeId } ?? Theme.defaultTheme

        let savedMode = UserDefaults.standard.string(forKey: "appearanceMode")
        appearanceMode = AppearanceMode(rawValue: savedMode ?? "auto") ?? .auto

        $currentTheme
            .dropFirst()
            .sink { [weak self] _ in self?.save() }
            .store(in: &cancellables)

        $appearanceMode
            .dropFirst()
            .sink { [weak self] _ in self?.save() }
            .store(in: &cancellables)
    }

    func save() {
        UserDefaults.standard.set(currentTheme.id, forKey: "selectedThemeId")
        UserDefaults.standard.set(appearanceMode.rawValue, forKey: "appearanceMode")
    }
}
