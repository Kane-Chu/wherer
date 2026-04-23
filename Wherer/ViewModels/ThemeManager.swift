import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var currentTheme: Theme
    @Published var appearanceMode: AppearanceMode
    @Published var systemColorScheme: ColorScheme = .light

    private var cancellables = Set<AnyCancellable>()

    var effectiveColors: ThemeColors {
        let isDark: Bool
        switch appearanceMode {
        case .auto:
            isDark = systemColorScheme == .dark
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

    private enum Keys {
        static let selectedThemeId = "selectedThemeId"
        static let appearanceMode = "appearanceMode"
    }

    init() {
        let savedThemeId = UserDefaults.standard.string(forKey: Keys.selectedThemeId)
        currentTheme = Theme.allThemes.first { $0.id == savedThemeId } ?? Theme.defaultTheme

        let savedMode = UserDefaults.standard.string(forKey: Keys.appearanceMode)
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

    private func save() {
        UserDefaults.standard.set(currentTheme.id, forKey: Keys.selectedThemeId)
        UserDefaults.standard.set(appearanceMode.rawValue, forKey: Keys.appearanceMode)
    }
}
