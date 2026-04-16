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
    @State private var selectedImages: [UIImage] = []
    @State private var coverIndex: Int = 0
    @State private var deletingIndex: Int?
    @State private var pickerImage: UIImage?
    @State private var imageSource: ImageSource?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 12) {
                        ZStack(alignment: .topTrailing) {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemGray6))
                                .frame(height: 160)
                                .overlay(
                                    Group {
                                        if !selectedImages.isEmpty {
                                            Image(uiImage: selectedImages[coverIndex])
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

                            if !selectedImages.isEmpty {
                                Text("封面")
                                    .font(.caption2.weight(.bold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .padding(8)
                            }
                        }

                        HStack(spacing: 16) {
                            Button {
                                imageSource = ImageSource(sourceType: .camera)
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "camera.fill")
                                    Text("拍照")
                                }
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(AppColors.primaryGradient)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))

                            Button {
                                imageSource = ImageSource(sourceType: .photoLibrary)
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "photo.fill")
                                    Text("相册")
                                }
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(Color(.systemGray5))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                            }
                        }

                        if !selectedImages.isEmpty {
                            HStack(spacing: 12) {
                                Button {
                                    imageSource = ImageSource(sourceType: .camera)
                                } label: {
                                    Image(systemName: "camera.fill")
                                        .font(.subheadline.weight(.semibold))
                                        .frame(width: 44, height: 44)
                                        .background(AppColors.primaryGradient)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))

                                Button {
                                    imageSource = ImageSource(sourceType: .photoLibrary)
                                } label: {
                                    Image(systemName: "photo.fill")
                                        .font(.subheadline.weight(.semibold))
                                        .frame(width: 44, height: 44)
                                        .background(Color(.systemGray5))
                                        .foregroundColor(.primary)
                                        .cornerRadius(10)
                                }
                            }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                                        ZStack {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 64, height: 64)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(coverIndex == index ? Color.accentColor : Color.clear, lineWidth: 3)
                                                )
                                                .onTapGesture {
                                                    coverIndex = index
                                                    deletingIndex = nil
                                                }
                                                .onLongPressGesture {
                                                    deletingIndex = index
                                                }

                                            if deletingIndex == index {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color.black.opacity(0.4))
                                                    .frame(width: 64, height: 64)

                                                Button {
                                                    selectedImages.remove(at: index)
                                                    if coverIndex >= selectedImages.count {
                                                        coverIndex = max(0, selectedImages.count - 1)
                                                    }
                                                    deletingIndex = nil
                                                } label: {
                                                    Image(systemName: "trash.fill")
                                                        .font(.title3)
                                                        .foregroundColor(.white)
                                                        .padding(8)
                                                        .background(Color.red)
                                                        .clipShape(Circle())
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
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
                        let cover = selectedImages.isEmpty ? nil : coverIndex
                        if let item = item {
                            itemStore.updateItem(item, name: name, location: location, space: targetSpace, category: category, tags: tags, images: selectedImages, coverIndex: cover)
                        } else {
                            itemStore.addItem(name: name, location: location, space: targetSpace, category: category, tags: tags, images: selectedImages, coverIndex: cover)
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
                    selectedImages = item.photoList.compactMap { PhotoService.loadPhoto(filename: $0.wrappedFilename) }
                    if selectedImages.isEmpty, let filename = item.photoFilename {
                        if let image = PhotoService.loadPhoto(filename: filename) {
                            selectedImages = [image]
                        }
                    }
                    coverIndex = item.photoList.firstIndex { $0.wrappedIsCover } ?? 0
                }
            }
            .fullScreenCover(item: $imageSource) { source in
                PhotoPicker(image: $pickerImage, sourceType: source.sourceType)
                    .ignoresSafeArea()
            }
            .onChange(of: pickerImage) { _, newImage in
                if let image = newImage {
                    selectedImages.append(image)
                    pickerImage = nil
                }
            }
        }
    }
}

struct ImageSource: Identifiable {
    let id = UUID()
    let sourceType: UIImagePickerController.SourceType
}
