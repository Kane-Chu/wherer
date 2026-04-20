# 物品编辑页重设计实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 `ItemFormView` 从标准 `Form` 样式重设计为清爽卡片式布局，包含独立的红色删除卡片、现代照片区域和自定义导航栏。

**Architecture:** 放弃 `Form`，改用 `ScrollView + VStack`，页面背景 `systemGroupedBackground`，内容用白色圆角卡片分组。Picker 用 `Button + sheet` 替代以保证卡片内视觉一致。删除用独立卡片 + `Alert` 确认。

**Tech Stack:** SwiftUI, iOS 16+, XCTest (UI 测试验证)

---

## 文件结构

| 文件 | 职责 |
|------|------|
| `Wherer/Views/Shared/ItemFormView.swift` | 唯一修改文件。重写 body 布局、所有子视图、添加删除确认弹窗 |

---

### Task 1: 重写主体框架 + 照片卡片

**Files:**
- Modify: `Wherer/Views/Shared/ItemFormView.swift`

**目标：** 将 body 从 `NavigationStack { Form { ... } }` 改为 `ScrollView + VStack + 卡片` 结构；重写导航栏为自定义取消/保存；重写照片区域为卡片式布局（预览 + 操作按钮 + 缩略图）。信息卡片和删除卡片先用 `EmptyView()` 占位，确保本 Task 编译通过。

- [ ] **Step 1: 替换 body、toolbar 和照片卡片**

将 `ItemFormView.swift` 中从 `var body` 到文件末尾（除 `PhotoSource` 和 `TestImageGenerator` 外）全部替换为以下代码：

```swift
    @State private var showingDeleteConfirm = false
    @State private var showingSpacePicker = false
    @State private var showingCategoryPicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 8) {
                        photoCard
                        infoCardPlaceholder
                        deleteCardPlaceholder
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
                    if let item = item {
                        itemStore.deleteItem(item)
                    }
                    dismiss()
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

    // MARK: - Placeholders (implemented in Task 2)

    private var infoCardPlaceholder: some View {
        EmptyView()
    }

    private var deleteCardPlaceholder: some View {
        EmptyView()
    }

    // MARK: - Navigation

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
        .background(Color(.systemBackground))
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
                    .background(AppColors.accent)
                    .foregroundColor(.white)
                    .cornerRadius(4)
                    .padding(10)
            }
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

    private var photoActionButtons: some View {
        HStack(spacing: 10) {
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
                                    .font(.system(size: 14, weight: .semibold))
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
                                    .foregroundColor(AppColors.accent)
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
                                    .foregroundColor(AppColors.accent)
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
```

- [ ] **Step 2: 编译验证**

Run: `xcodebuild -project Wherer.xcodeproj -scheme Wherer -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build`

Expected: BUILD SUCCEEDED（infoCard 和 deleteCard 是 EmptyView 占位，所以一定能编译）

- [ ] **Step 3: Commit**

```bash
git add Wherer/Views/Shared/ItemFormView.swift
git commit -m "refactor: redesign ItemFormView layout - body, toolbar, photo card"
```

---

### Task 2: 重写信息卡片 + 删除卡片

**Files:**
- Modify: `Wherer/Views/Shared/ItemFormView.swift`

**目标：** 将 `infoCardPlaceholder` 替换为完整的信息卡片（名称、位置、空间、类型、标签），将 `deleteCardPlaceholder` 替换为删除卡片。保持所有 `accessibilityIdentifier` 不变。

- [ ] **Step 1: 替换占位符为完整实现**

在 `ItemFormView.swift` 中，将 `infoCardPlaceholder` 和 `deleteCardPlaceholder` 两个 computed property 替换为以下代码：

```swift
    // MARK: - Info Card

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 物品名称
            TextField("物品名称", text: $name)
                .padding(.vertical, 14)
                .accessibilityIdentifier("itemNameField")

            Divider()
                .background(Color(.systemGray5))

            // 存放位置
            TextField("存放位置", text: $location)
                .padding(.vertical, 14)
                .accessibilityIdentifier("itemLocationField")

            Divider()
                .background(Color(.systemGray5))

            // 所属空间
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

            // 类型
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

            // 标签
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
                                .background(AppColors.accent.opacity(0.12))
                                .foregroundColor(AppColors.accent)
                                .cornerRadius(12)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
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
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                }
            }
        }
    }
```

同时，将 body 中的引用从 `infoCardPlaceholder` 改为 `infoCard`，从 `deleteCardPlaceholder` 改为 `deleteCard`：

```swift
                    VStack(spacing: 8) {
                        photoCard
                        infoCard
                        deleteCard
                    }
```

- [ ] **Step 2: 编译验证**

Run: `xcodebuild -project Wherer.xcodeproj -scheme Wherer -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build`

Expected: BUILD SUCCEEDED

- [ ] **Step 3: Commit**

```bash
git add Wherer/Views/Shared/ItemFormView.swift
git commit -m "refactor: redesign ItemFormView - info card, delete card, tag pills"
```

---

### Task 3: UI 测试验证

**Files:**
- 无需修改代码，运行已有测试
- Test: `WhererUITests/WhererUITests.swift`

**目标：** 运行 UI 测试确保编辑页功能正常，截图检查视觉效果。

- [ ] **Step 1: 运行 UI 测试**

Run: `./run-ui-tests.sh`

Expected: 所有 4 个测试通过（testAddNewItem, testCancelAddItem, testSaveButtonDisabledWhenEmpty, testScreenshotItemDetail）

- [ ] **Step 2: 检查截图**

检查 `ui-test-screenshots/` 目录下的截图：
- `02_AddForm_Empty` — 空表单，应显示：照片卡片（灰色预览区 + 三个操作按钮）、信息卡片（空字段）、无删除卡片
- `03_AddForm_Filled` — 填写后的表单，应显示：名称/位置已填、标签胶囊预览
- `05_CancelAdd_Form` — 取消添加的表单，布局正常

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "test: verify redesigned ItemFormView with UI tests"
```

---

## Spec 自检

**1. Spec coverage:**
- ✅ 放弃 Form → ScrollView + VStack — Task 1 Step 1
- ✅ 白色圆角卡片分组 — Task 1 Step 1 (photoCard), Task 2 Step 1 (infoCard, deleteCard)
- ✅ 自定义导航栏取消/保存 — Task 1 Step 1 (formToolbar)
- ✅ 照片卡片（预览 + 按钮 + 缩略图）— Task 1 Step 1
- ✅ 信息卡片（名称/位置/空间/类型/标签）— Task 2 Step 1
- ✅ 标签胶囊预览 — Task 2 Step 1 (parsedTags)
- ✅ 删除卡片（红色文字）— Task 2 Step 1
- ✅ 删除确认弹窗 — Task 1 Step 1 (alert)
- ✅ Picker 用 Button + sheet — Task 1 Step 1 (spacePickerSheet, categoryPickerSheet)
- ✅ 保持 accessibilityIdentifier — 所有 Task

**2. Placeholder scan:**
- ✅ 无 TBD/TODO/implement later
- ✅ 每个步骤包含完整代码
- ✅ 每个步骤包含验证命令

**3. Type consistency:**
- ✅ `@State` 变量名一致
- ✅ `saveDisabled`、`saveItem`、`loadItemData` 等现有方法保留
- ✅ `PhotoPickerPresenter`、`PhotoSource`、`TestImageGenerator` 未改动
