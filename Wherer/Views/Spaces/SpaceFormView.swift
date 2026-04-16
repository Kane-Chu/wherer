import SwiftUI

struct SpaceFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var spaceStore: SpaceStore

    var space: Space?
    @State private var name: String = ""
    @State private var icon: String = "house"
    @State private var selectedPreset: ColorPreset = ColorPreset.allPresets[0]

    private let icons = [
        "house", "bed.double.fill", "book.fill", "sofa.fill",
        "archivebox.fill", "car.fill", "tree.fill", "cup.and.saucer.fill"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("空间名称", text: $name)
                    Picker("图标", selection: $icon) {
                        ForEach(icons, id: \.self) { icon in
                            Label(icon, systemImage: icon).tag(icon)
                        }
                    }
                }

                Section("配色") {
                    ColorPresetPicker(selected: $selectedPreset)
                }
            }
            .navigationTitle(space == nil ? "添加空间" : "编辑空间")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        if let space = space {
                            spaceStore.updateSpace(space, name: name, icon: icon, colorHex: selectedPreset.startHex)
                        } else {
                            spaceStore.addSpace(name: name, icon: icon, colorHex: selectedPreset.startHex)
                        }
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let space = space {
                    name = space.wrappedName
                    icon = space.wrappedIcon
                    selectedPreset = ColorPreset.allPresets.first {
                        space.wrappedColorHex == $0.startHex
                    } ?? ColorPreset.allPresets[0]
                }
            }
        }
    }
}
