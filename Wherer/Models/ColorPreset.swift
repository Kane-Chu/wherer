import SwiftUI

struct ColorPreset: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let startHex: String
    let endHex: String

    var startColor: Color { Color(hex: startHex) }
    var endColor: Color { Color(hex: endHex) }

    static let allPresets: [ColorPreset] = [
        ColorPreset(name: "暖阳橙", startHex: "#ffeaa7", endHex: "#fab1a0"),
        ColorPreset(name: "薄荷青", startHex: "#a8edea", endHex: "#fed6e3"),
        ColorPreset(name: "薰衣草", startHex: "#d299c2", endHex: "#fef9d7"),
        ColorPreset(name: "天空蓝", startHex: "#89f7fe", endHex: "#66a6ff"),
        ColorPreset(name: "森林绿", startHex: "#d4fc79", endHex: "#96e6a1"),
        ColorPreset(name: "珊瑚粉", startHex: "#ff9a9e", endHex: "#fecfef"),
        ColorPreset(name: "深海蓝", startHex: "#a1c4fd", endHex: "#c2e9fb"),
        ColorPreset(name: "落日红", startHex: "#ffecd2", endHex: "#fcb69f")
    ]

    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [startColor, endColor]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
