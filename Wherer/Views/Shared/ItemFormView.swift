import SwiftUI

struct ItemFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var spaceStore: SpaceStore

    let space: Space
    var item: Item?

    @State private var name: String = ""
    @State private var location: String = ""
    @State private var selectedSpace: Space?
    @State private var category: Category = .other
    @State private var tags: String = ""
    @State private var selectedImage: UIImage?
    @State private var imageSource: ImageSource?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemGray6))
                                .frame(height: 160)
                                .overlay(
                                    Group {
                                        if let image = selectedImage {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(height: 160)
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                        } else {
                                            VStack(spacing: 8) {
                                                Image(systemName: "camera.fill")
                                                    .font(.title2)
                                                    .foregroundColor(.secondary)
                                                Text("点击拍照或从相册选择")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                )
                        }

                        HStack(spacing: 12) {
                            Button {
                                imageSource = ImageSource(sourceType: .camera)
                            } label: {
                                Label("拍照", systemImage: "camera.fill")
                                    .font(.subheadline.weight(.medium))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(AppColors.primaryGradient)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))

                            Button {
                                imageSource = ImageSource(sourceType: .photoLibrary)
                            } label: {
                                Label("相册", systemImage: "photo.fill")
                                    .font(.subheadline.weight(.medium))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color(.systemGray5))
                                    .foregroundColor(.primary)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                Section("基本信息") {
                    TextField("物品名称", text: $name)
                    TextField("存放位置", text: $location)
                    Picker("所属空间", selection: $selectedSpace) {
                        ForEach(spaceStore.spaces) { space in
                            Text(space.wrappedName).tag(space as Space?)
                        }
                    }
                    Picker("类型", selection: $category) {
                        ForEach(Category.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    TextField("标签（用逗号分隔）", text: $tags)
                }
            }
            .navigationTitle(item == nil ? "添加物品" : "编辑物品")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        guard let targetSpace = selectedSpace else { return }
                        if let item = item {
                            itemStore.updateItem(item, name: name, location: location, space: targetSpace, category: category, tags: tags, image: selectedImage)
                        } else {
                            itemStore.addItem(name: name, location: location, space: targetSpace, category: category, tags: tags, image: selectedImage)
                        }
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || selectedSpace == nil)
                }
            }
            .onAppear {
                selectedSpace = space
                if let item = item {
                    name = item.wrappedName
                    location = item.wrappedLocation
                    selectedSpace = item.wrappedSpace
                    category = item.wrappedCategory
                    tags = item.tags ?? ""
                    if let filename = item.wrappedPhotoFilename {
                        selectedImage = PhotoService.loadPhoto(filename: filename)
                    }
                }
            }
            .fullScreenCover(item: $imageSource) { source in
                PhotoPicker(image: $selectedImage, sourceType: source.sourceType)
                    .ignoresSafeArea()
            }
        }
    }
}

struct ImageSource: Identifiable {
    var id: String { sourceType == .camera ? "camera" : "library" }
    let sourceType: UIImagePickerController.SourceType
}
