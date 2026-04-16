import SwiftUI

enum AppColors {
    static let primaryGradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "#667eea"), Color(hex: "#764ba2")]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accent = Color(hex: "#667eea")
}
