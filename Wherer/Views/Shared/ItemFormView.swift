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
    @State private var showingImagePicker = false
    @State private var showingSourceSheet = false
    @State private var pickerSourceType: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        NavigationStack {
            Form {
                Section {
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
                            .onTapGesture {
                                showingSourceSheet = true
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
            .confirmationDialog("选择照片来源", isPresented: $showingSourceSheet, titleVisibility: .visible) {
                Button("拍照") {
                    pickerSourceType = .camera
                    showingImagePicker = true
                }
                Button("从相册选择") {
                    pickerSourceType = .photoLibrary
                    showingImagePicker = true
                }
                Button("取消", role: .cancel) {}
            }
            .sheet(isPresented: $showingImagePicker) {
                PhotoPicker(image: $selectedImage, sourceType: pickerSourceType)
            }
        }
    }
}
