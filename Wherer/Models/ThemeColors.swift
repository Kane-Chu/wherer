import SwiftUI

struct ThemeColors {
    let accent: Color
    let gradientStart: Color
    let gradientEnd: Color
    let background: Color
    let groupedBackground: Color
    let cardBackground: Color
    let tagTint: Color
    let tagTintOpacity: Double

    var primaryGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [gradientStart, gradientEnd]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
