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
    @State private var photoSource: PhotoSource?
    @State private var pickerImage: UIImage?
    @State private var isPickingPhoto = false

    var body: some View {
        NavigationStack {
            Form {
                photoSection
                basicInfoSection
            }
            .navigationTitle(navigationTitle)
            .toolbar { formToolbar }
            .onAppear(perform: loadItemData)
            .onChange(of: pickerImage, handlePickerImage)
            .onChange(of: photoSource, handlePhotoSourceChange)
        }
        .overlay(
            PhotoPickerPresenter(photoSource: $photoSource, image: $pickerImage)
                .allowsHitTesting(false)
        )
    }

    private var navigationTitle: String {
        item == nil ? "添加物品" : "编辑物品"
    }

    private var photoSection: some View {
        Section {
            VStack(spacing: 16) {
                photoPreview
                photoActionButtons
                if !selectedImages.isEmpty {
                    thumbnailScroll
                }
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
    }

    private var photoPreview: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
                .frame(height: 180)
                .overlay(previewContent)

            if !selectedImages.isEmpty {
                coverLabel
            }
        }
    }

    private var coverLabel: some View {
        Text("封面")
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(8)
    }

    private var basicInfoSection: some View {
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

    private var formToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("保存", action: saveItem)
                    .disabled(saveDisabled)
            }
        }
    }

    private var saveDisabled: Bool {
        name.trimmingCharacters(in: .whitespaces).isEmpty || selectedSpace == nil
    }

    private func saveItem() {
        guard let targetSpace = selectedSpace else { return }
        var imagesToSave = selectedImages
        if imagesToSave.isEmpty, let pending = pickerImage {
            imagesToSave = [pending]
        }
        let cover = imagesToSave.isEmpty ? nil : coverIndex
        if let item = item {
            itemStore.updateItem(item, name: name, location: location, space: targetSpace, category: category, tags: tags, images: imagesToSave, coverIndex: cover)
        } else {
            itemStore.addItem(name: name, location: location, space: targetSpace, category: category, tags: tags, images: imagesToSave, coverIndex: cover)
        }
        dismiss()
    }

    private func loadItemData() {
        guard selectedImages.isEmpty else { return }
        selectedSpace = space
        guard let item = item else { return }
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

    private func handlePickerImage(_ old: UIImage?, _ new: UIImage?) {
        if let image = new {
            selectedImages.append(image)
            pickerImage = nil
        }
    }

    private func handlePhotoSourceChange(_ old: PhotoSource?, _ new: PhotoSource?) {
        if new == nil {
            isPickingPhoto = false
        }
    }

    private var photoActionButtons: some View {
        HStack(spacing: 16) {
            cameraButtonLabel
                .onTapGesture(perform: openCamera)
                .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))

            albumButtonLabel
                .onTapGesture(perform: openAlbum)

            #if DEBUG
            debugTestImageButton
            #endif
        }
    }

    #if DEBUG
    private var debugTestImageButton: some View {
        Button {
            selectedImages.append(TestImageGenerator.generate())
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "bolt.fill")
                Text("测试图")
            }
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(Color.green.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
    #endif

    private func openCamera() {
        guard !isPickingPhoto else { return }
        isPickingPhoto = true
        photoSource = PhotoSource(sourceType: .camera)
    }

    private func openAlbum() {
        guard !isPickingPhoto else { return }
        isPickingPhoto = true
        photoSource = PhotoSource(sourceType: .photoLibrary)
    }

    private var cameraButtonLabel: some View {
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

    private var albumButtonLabel: some View {
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

    private var thumbnailScroll: some View {
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
                                    .stroke(coverIndex == index ? AppColors.accent : Color.clear, lineWidth: 3)
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

    @ViewBuilder
    private var previewContent: some View {
        if !selectedImages.isEmpty {
            Image(uiImage: selectedImages[coverIndex])
                .resizable()
                .scaledToFill()
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        } else {
            VStack(spacing: 10) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundColor(.secondary)
                Text("点击拍照或从相册选择")
                    .font(.body.weight(.medium))
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct PhotoSource: Identifiable, Equatable {
    let id = UUID()
    let sourceType: UIImagePickerController.SourceType
}

enum TestImageGenerator {
    static func generate() -> UIImage {
        let size = CGSize(width: 300, height: 300)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemTeal]
            let color = colors.randomElement()!
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            let text = "\(Int.random(in: 1...99))"
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 72, weight: .bold),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
}
