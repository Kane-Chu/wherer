import SwiftUI

struct Theme: Identifiable {
    let id: String
    let name: String
    let icon: String
    let light: ThemeColors
    let dark: ThemeColors

    static let allThemes: [Theme] = [
        starry, sunset, mint, midnight, sakura
    ]

    static let defaultTheme = starry

    // MARK: - 1. 紫蓝星空
    static let starry = Theme(
        id: "starry",
        name: "紫蓝星空",
        icon: "sparkles",
        light: ThemeColors(
            accent: Color(hex: "#667eea"),
            gradientStart: Color(hex: "#667eea"),
            gradientEnd: Color(hex: "#764ba2"),
            background: Color(hex: "#ffffff"),
            groupedBackground: Color(hex: "#f2f2f7"),
            cardBackground: Color(hex: "#f8f9ff"),
            tagTint: Color(hex: "#667eea"),
            tagTintOpacity: 0.12
        ),
        dark: ThemeColors(
            accent: Color(hex: "#8b9cf0"),
            gradientStart: Color(hex: "#5a6fd6"),
            gradientEnd: Color(hex: "#8a6bc9"),
            background: Color(hex: "#000000"),
            groupedBackground: Color(hex: "#1c1c1e"),
            cardBackground: Color(hex: "#1a1d2e"),
            tagTint: Color(hex: "#8b9cf0"),
            tagTintOpacity: 0.18
        )
    )

    // MARK: - 2. 日落暖橙
    static let sunset = Theme(
        id: "sunset",
        name: "日落暖橙",
        icon: "sun.max.fill",
        light: ThemeColors(
            accent: Color(hex: "#ff7e5f"),
            gradientStart: Color(hex: "#ff7e5f"),
            gradientEnd: Color(hex: "#feb47b"),
            background: Color(hex: "#fffaf8"),
            groupedBackground: Color(hex: "#fff5f0"),
            cardBackground: Color(hex: "#ffffff"),
            tagTint: Color(hex: "#ff7e5f"),
            tagTintOpacity: 0.12
        ),
        dark: ThemeColors(
            accent: Color(hex: "#ff9a7e"),
            gradientStart: Color(hex: "#d66a4f"),
            gradientEnd: Color(hex: "#cc9468"),
            background: Color(hex: "#1a1410"),
            groupedBackground: Color(hex: "#241c18"),
            cardBackground: Color(hex: "#2d2420"),
            tagTint: Color(hex: "#ff9a7e"),
            tagTintOpacity: 0.18
        )
    )

    // MARK: - 3. 薄荷清新
    static let mint = Theme(
        id: "mint",
        name: "薄荷清新",
        icon: "leaf.fill",
        light: ThemeColors(
            accent: Color(hex: "#00b894"),
            gradientStart: Color(hex: "#00b894"),
            gradientEnd: Color(hex: "#00cec9"),
            background: Color(hex: "#f8fffd"),
            groupedBackground: Color(hex: "#f0faf7"),
            cardBackground: Color(hex: "#ffffff"),
            tagTint: Color(hex: "#00b894"),
            tagTintOpacity: 0.12
        ),
        dark: ThemeColors(
            accent: Color(hex: "#55efc4"),
            gradientStart: Color(hex: "#009973"),
            gradientEnd: Color(hex: "#00a8a3"),
            background: Color(hex: "#0f1a18"),
            groupedBackground: Color(hex: "#142420"),
            cardBackground: Color(hex: "#1a2e2b"),
            tagTint: Color(hex: "#55efc4"),
            tagTintOpacity: 0.18
        )
    )

    // MARK: - 4. 暗夜深邃
    static let midnight = Theme(
        id: "midnight",
        name: "暗夜深邃",
        icon: "moon.stars.fill",
        light: ThemeColors(
            accent: Color(hex: "#2c3e50"),
            gradientStart: Color(hex: "#2c3e50"),
            gradientEnd: Color(hex: "#34495e"),
            background: Color(hex: "#f0f2f5"),
            groupedBackground: Color(hex: "#e8eaed"),
            cardBackground: Color(hex: "#ffffff"),
            tagTint: Color(hex: "#2c3e50"),
            tagTintOpacity: 0.12
        ),
        dark: ThemeColors(
            accent: Color(hex: "#5d8aa8"),
            gradientStart: Color(hex: "#3a506b"),
            gradientEnd: Color(hex: "#5d8aa8"),
            background: Color(hex: "#0d1117"),
            groupedBackground: Color(hex: "#13171f"),
            cardBackground: Color(hex: "#161b22"),
            tagTint: Color(hex: "#5d8aa8"),
            tagTintOpacity: 0.18
        )
    )

    // MARK: - 5. 樱花粉嫩
    static let sakura = Theme(
        id: "sakura",
        name: "樱花粉嫩",
        icon: "flower.fill",
        light: ThemeColors(
            accent: Color(hex: "#ff6b9d"),
            gradientStart: Color(hex: "#ff6b9d"),
            gradientEnd: Color(hex: "#feca57"),
            background: Color(hex: "#fff8fb"),
            groupedBackground: Color(hex: "#fff0f5"),
            cardBackground: Color(hex: "#ffffff"),
            tagTint: Color(hex: "#ff6b9d"),
            tagTintOpacity: 0.12
        ),
        dark: ThemeColors(
            accent: Color(hex: "#ff8fb0"),
            gradientStart: Color(hex: "#d6597d"),
            gradientEnd: Color(hex: "#d4a84a"),
            background: Color(hex: "#1a1015"),
            groupedBackground: Color(hex: "#241820"),
            cardBackground: Color(hex: "#2d1c25"),
            tagTint: Color(hex: "#ff8fb0"),
            tagTintOpacity: 0.18
        )
    )
}
