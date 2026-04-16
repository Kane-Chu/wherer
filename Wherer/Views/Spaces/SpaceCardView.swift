import SwiftUI

struct SpaceCardView: View {
    let space: Space

    private var preset: ColorPreset? {
        ColorPreset.allPresets.first { space.wrappedColorHex == $0.startHex }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Spacer()
            Image(systemName: space.wrappedIcon)
                .font(.title2)
                .foregroundColor(.primary.opacity(0.8))
            Text(space.wrappedName)
                .font(.headline)
                .foregroundColor(.primary.opacity(0.9))
            Text("\(space.itemCount) 件物品")
                .font(.caption)
                .foregroundColor(.primary.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            Group {
                if let preset = preset {
                    AnyView(preset.gradient)
                } else {
                    AnyView(Color(hex: space.wrappedColorHex))
                }
            }
        )
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}
