import SwiftUI

struct ItemFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var spaceStore: SpaceStore
    @EnvironmentObject var themeManager: ThemeManager

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
    @State private var showingDeleteConfirm = false
    @State private var showingSpacePicker = false
    @State private var showingCategoryPicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.effectiveColors.groupedBackground
                    .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 8) {
                        photoCard
                        infoCard
                        deleteCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { formToolbar }
            .sheet(isPresented: $showingSpacePicker) { spacePickerSheet }
            .sheet(isPresented: $showingCategoryPicker) { categoryPickerSheet }
            .alert("确认删除？", isPresented: $showingDeleteConfirm) {
                Button("取消", role: .cancel) {}
                Button("删除", role: .destructive) {
                    dismiss()
                    if let item = item {
                        itemStore.deleteItem(item)
                    }
                }
            } message: {
                Text("删除后将无法恢复")
            }
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

    // MARK: - Info Card

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("物品名称", text: $name)
                .padding(.vertical, 14)
                .accessibilityIdentifier("itemNameField")

            Divider()
                .background(Color(.systemGray5))

            TextField("存放位置", text: $location)
                .padding(.vertical, 14)
                .accessibilityIdentifier("itemLocationField")

            Divider()
                .background(Color(.systemGray5))

            Button {
                showingSpacePicker = true
            } label: {
                HStack {
                    Text("所属空间")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(selectedSpace?.wrappedName ?? "-")
                        .foregroundColor(.primary)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 14)
            }
            .foregroundColor(.primary)
            .accessibilityIdentifier("itemSpacePicker")

            Divider()
                .background(Color(.systemGray5))

            Button {
                showingCategoryPicker = true
            } label: {
                HStack {
                    Text("类型")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(category.rawValue)
                        .foregroundColor(.primary)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 14)
            }
            .foregroundColor(.primary)
            .accessibilityIdentifier("itemCategoryPicker")

            Divider()
                .background(Color(.systemGray5))

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("标签")
                        .foregroundColor(.secondary)
                    Spacer()
                    TextField("用逗号分隔", text: $tags)
                        .multilineTextAlignment(.trailing)
                        .accessibilityIdentifier("itemTagsField")
                }
                .padding(.vertical, 14)

                if !parsedTags.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(parsedTags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(themeManager.effectiveColors.tagTint.opacity(themeManager.effectiveColors.tagTintOpacity))
                                .foregroundColor(themeManager.effectiveColors.accent)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.bottom, 14)
                }
            }
        }
        .padding(.horizontal, 16)
        .background(themeManager.effectiveColors.cardBackground)
        .cornerRadius(20)
    }

    private var parsedTags: [String] {
        tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }

    // MARK: - Delete Card

    private var deleteCard: some View {
        Group {
            if item != nil {
                Button {
                    showingDeleteConfirm = true
                } label: {
                    HStack {
                        Spacer()
                        Text("删除物品")
                            .font(.body.weight(.medium))
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding(.vertical, 14)
                    .background(themeManager.effectiveColors.cardBackground)
                    .cornerRadius(20)
                }
            }
        }
    }

    // MARK: - Photo Card

    private var photoCard: some View {
        VStack(spacing: 12) {
            photoPreview
            photoActionButtons
            if !selectedImages.isEmpty {
                thumbnailScroll
            }
        }
        .padding(16)
        .background(themeManager.effectiveColors.cardBackground)
        .cornerRadius(20)
    }

    private var photoPreview: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .frame(height: 160)
                .overlay(previewContent)

            if !selectedImages.isEmpty {
                Text("封面")
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(themeManager.effectiveColors.accent)
                    .foregroundColor(.white)
                    .cornerRadius(4)
                    .padding(10)
            }
        }
    }

    // MARK: - Picker Sheets

    private var spacePickerSheet: some View {
        NavigationStack {
            List {
                ForEach(spaceStore.spaces) { sp in
                    Button {
                        selectedSpace = sp
                        showingSpacePicker = false
                    } label: {
                        HStack {
                            Text(sp.wrappedName)
                                .foregroundColor(.primary)
                            Spacer()
                            if sp.wrappedId == selectedSpace?.wrappedId {
                                Image(systemName: "checkmark")
                                    .foregroundColor(themeManager.effectiveColors.accent)
                            }
                        }
                    }
                }
            }
            .navigationTitle("选择空间")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("完成") { showingSpacePicker = false }
                }
            }
        }
    }

    private var categoryPickerSheet: some View {
        NavigationStack {
            List {
                ForEach(Category.allCases) { cat in
                    Button {
                        category = cat
                        showingCategoryPicker = false
                    } label: {
                        HStack {
                            Text(cat.rawValue)
                                .foregroundColor(.primary)
                            Spacer()
                            if category == cat {
                                Image(systemName: "checkmark")
                                    .foregroundColor(themeManager.effectiveColors.accent)
                            }
                        }
                    }
                }
            }
            .navigationTitle("选择类型")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("完成") { showingCategoryPicker = false }
                }
            }
        }
    }

    private var formToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .topBarLeading) {
                Button("取消") { dismiss() }
                    .accessibilityIdentifier("itemFormCancelButton")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("保存", action: saveItem)
                    .fontWeight(.semibold)
                    .disabled(saveDisabled)
                    .accessibilityIdentifier("itemFormSaveButton")
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
        selectedImages = item.photoList.compactMap { $0.image }
        if selectedImages.isEmpty, let image = item.coverImage {
            selectedImages = [image]
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
        .background(themeManager.effectiveColors.primaryGradient)
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
                                    .stroke(coverIndex == index ? themeManager.effectiveColors.accent : Color.clear, lineWidth: 3)
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
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        } else {
            VStack(spacing: 8) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(.secondary)
                Text("点击添加照片")
                    .font(.subheadline)
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
