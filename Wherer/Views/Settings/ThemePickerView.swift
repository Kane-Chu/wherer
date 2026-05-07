import SwiftUI

struct ThemePickerView: View {
    @EnvironmentObject var themeManager: ThemeManager

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(Theme.allThemes) { theme in
                ThemeCard(theme: theme, isSelected: themeManager.currentTheme.id == theme.id) {
                    themeManager.currentTheme = theme
                }
            }
        }
    }
}

struct ThemeCard: View {
    let theme: Theme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(theme.light.primaryGradient)
                        .frame(height: 80)
                        .overlay(
                            Image(systemName: theme.icon)
                                .font(.title2)
                                .foregroundColor(.white)
                        )

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.black.opacity(0.3)))
                            .padding(8)
                    }
                }

                Text(theme.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(.plain)
    }
}
