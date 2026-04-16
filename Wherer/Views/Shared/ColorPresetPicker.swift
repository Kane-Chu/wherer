import SwiftUI

struct ColorPresetPicker: View {
    @Binding var selected: ColorPreset

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 12) {
            ForEach(ColorPreset.allPresets) { preset in
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(preset.gradient)
                        .frame(width: 60, height: 60)
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)

                    if preset.id == selected.id {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primary, lineWidth: 3)
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(preset.name)
                .accessibilityAddTraits(preset.id == selected.id ? .isSelected : [])
                .onTapGesture {
                    withAnimation(.spring()) {
                        selected = preset
                    }
                }
            }
        }
    }
}
