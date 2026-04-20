# 物品详情页 Redesign 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 `ItemDetailView` 从平铺布局重设计为沉浸大图 + 信息分区布局，提供返回按钮、更多操作菜单，改善删除按钮的视觉协调性。

**Architecture:** 重写 `ItemDetailView` body 为分层结构（顶部大图区 + 信息区），提取 `InfoRow` 组件用于 Label-Value 展示，用 `confirmationDialog` 替代 Alert 实现 Action Sheet 风格菜单。

**Tech Stack:** SwiftUI, iOS 16+, CoreData (Item, ItemPhoto)

---

## 文件结构

| 文件 | 职责 |
|------|------|
| `Wherer/Views/Shared/ItemDetailView.swift` | 主视图，重写布局 + 交互 |
| `Wherer/Views/Shared/ImagePreviewView.swift` | 复用，无改动 |
| `Wherer/Views/Shared/ItemFormView.swift` | 复用，无改动 |

---

### Task 1: 重写封面图区域

**Files:**
- Modify: `Wherer/Views/Shared/ItemDetailView.swift:18-61`（图片区域）

**Context:** 当前封面图是一个横向 ScrollView，高度 180。新设计需要 260pt 全宽大图，叠加返回/更多毛玻璃按钮和标题。

- [ ] **Step 1: 添加 @State 用于更多菜单**

在 `ItemDetailView` 顶部添加：

```swift
@State private var showingActionSheet = false
```

- [ ] **Step 2: 重写图片区域为 ZStack 叠加结构**

替换当前 `if !photos.isEmpty` 和 `else if let filename` 的展示逻辑为统一的 `coverImageSection`：

```swift
private var coverImageSection: some View {
    ZStack(alignment: .bottomLeading) {
        // 图片内容
        coverImageContent
            .frame(height: 260)
            .clipped()

        // 顶部渐变遮罩 + 按钮
        LinearGradient(
            colors: [.black.opacity(0.4), .clear],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 100)
        .overlay(alignment: .top) {
            HStack {
                backButton
                Spacer()
                moreButton
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }

        // 底部渐变遮罩 + 标题
        LinearGradient(
            colors: [.clear, .black.opacity(0.5)],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 100)
        .overlay(alignment: .bottomLeading) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.wrappedName)
                    .font(.title3.weight(.bold))
                    .foregroundColor(.white)
                Text(item.wrappedLocation)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(16)
        }
    }
}

private var coverImageContent: some View {
    Group {
        if !photos.isEmpty {
            TabView {
                ForEach(Array(photos.enumerated()), id: \.offset) { index, photo in
                    if let image = PhotoService.loadPhoto(filename: photo.wrappedFilename) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .onTapGesture {
                                previewImage = PreviewImage(image: image)
                            }
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: photos.count > 1 ? .always : .never))
        } else if let filename = item.photoFilename,
                  let image = PhotoService.loadPhoto(filename: filename) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .onTapGesture {
                    previewImage = PreviewImage(image: image)
                }
        } else {
            Color(.systemGray5)
                .overlay(
                    Image(systemName: item.wrappedCategory.icon)
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                )
        }
    }
}

private var backButton: some View {
    Button {
        dismiss()
    } label: {
        Image(systemName: "chevron.left")
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 36, height: 36)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
    }
}

private var moreButton: some View {
    Button {
        showingActionSheet = true
    } label: {
        Image(systemName: "ellipsis")
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 36, height: 36)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
    }
}
```

- [ ] **Step 3: 在 body 中使用新的 coverImageSection**

把 body 中原来的图片展示逻辑替换为 `coverImageSection`，去掉 `VStack` 中原来的图片条件分支。

- [ ] **Step 4: 添加 confirmationDialog 修饰符**

在 body 末尾（`.onAppear` 之后）添加：

```swift
.confirmationDialog("更多", isPresented: $showingActionSheet, titleVisibility: .hidden) {
    Button("编辑物品") {
        showingEdit = true
    }
    Button("删除物品", role: .destructive) {
        showingDeleteConfirm = true
    }
    Button("取消", role: .cancel) {}
}
```

- [ ] **Step 5: 去掉旧 toolbar**

删除 `.navigationTitle(item.wrappedName)` 和 `.toolbar { ... }` 块，因为导航栏已被毛玻璃按钮替代。

- [ ] **Step 6: Build 验证**

Run: `xcodebuild -project Wherer.xcodeproj -scheme Wherer -destination 'id=54A76C4B-4AB5-45E0-91D3-EC5DC0BABA3B' -derivedDataPath build build 2>&1 | tail -5`
Expected: **BUILD SUCCEEDED**

---

### Task 2: 重写信息区

**Files:**
- Modify: `Wherer/Views/Shared/ItemDetailView.swift:62-87`（信息区 + DetailRow）
- Delete: `DetailRow` struct

**Context:** 当前用 `DetailRow` 组件（标题左对齐 + 值右对齐，固定 60pt 宽度）。新设计需要 Label-Value 垂直堆叠 + 分割线。

- [ ] **Step 1: 替换信息区为新的 infoSection**

替换原来的 `VStack(alignment: .leading, spacing: 12) { DetailRow(...) }` 为：

```swift
private var infoSection: some View {
    VStack(alignment: .leading, spacing: 0) {
        InfoRow(label: "空间", value: item.wrappedSpace?.wrappedName ?? "-")
        Divider()
        InfoRow(label: "类型", value: item.wrappedCategory.rawValue)
        Divider()
        InfoRow(label: "标签") {
            if !item.wrappedTags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(item.wrappedTags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.12))
                            .foregroundColor(.accentColor)
                            .cornerRadius(12)
                    }
                }
            } else {
                Text("-")
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
        Divider()
        InfoRow(label: "更新于", value: item.wrappedUpdatedAt.formatted())
    }
    .padding(.horizontal, 16)
}
```

- [ ] **Step 2: 添加 InfoRow 组件**

在 `ItemDetailView` 下方添加：

```swift
struct InfoRow<Content: View>: View {
    let label: String
    let content: Content

    init(label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    init(label: String, value: String) where Content == Text {
        self.label = label
        self.content = Text(value)
            .font(.body)
            .foregroundColor(.primary)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
            content
        }
        .padding(.vertical, 12)
    }
}
```

- [ ] **Step 3: 删除旧 DetailRow**

删除 `DetailRow` struct 的定义（当前在 `ItemDetailView` 之后）。

- [ ] **Step 4: 更新 body 结构**

确保 body 中的布局顺序是：
1. `coverImageSection`
2. `infoSection`
3. （底部删除按钮已移除）

删除原来的 `Spacer()` 和红色删除 `Button` 代码块。

- [ ] **Step 5: Build 验证**

Run: `xcodebuild -project Wherer.xcodeproj -scheme Wherer -destination 'id=54A76C4B-4AB5-45E0-91D3-EC5DC0BABA3B' -derivedDataPath build build 2>&1 | tail -5`
Expected: **BUILD SUCCEEDED**

---

### Task 3: 清理旧代码并验证交互

**Files:**
- Modify: `Wherer/Views/Shared/ItemDetailView.swift`（清理残留）

- [ ] **Step 1: 删除不再需要的 @State**

`showingDeleteConfirm` 仍然需要（Action Sheet 点击删除后弹出确认）。检查并确认保留：
- `@State private var showingDeleteConfirm = false` — 保留（删除确认弹窗）
- `@State private var showingEdit = false` — 保留（编辑 sheet）
- `@State private var showingActionSheet = false` — 保留（更多菜单）

- [ ] **Step 2: 确认删除确认 alert 仍有效**

保留现有的 `.alert("确认删除？", isPresented: $showingDeleteConfirm) { ... }` 修饰符，确保点击 Action Sheet 中的"删除物品"后正确触发。

- [ ] **Step 3: 确认编辑 sheet 仍有效**

保留现有的 `.sheet(isPresented: $showingEdit, onDismiss: { photos = item.photoList }) { ... }` 修饰符。

- [ ] **Step 4: 确认图片预览仍有效**

保留现有的 `.fullScreenCover(item: $previewImage) { ... }` 修饰符。

- [ ] **Step 5: Build 验证**

Run: `xcodebuild -project Wherer.xcodeproj -scheme Wherer -destination 'id=54A76C4B-4AB5-45E0-91D3-EC5DC0BABA3B' -derivedDataPath build build 2>&1 | tail -5`
Expected: **BUILD SUCCEEDED**

- [ ] **Step 6: Commit**

```bash
git add Wherer/Views/Shared/ItemDetailView.swift
git commit -m "refactor: redesign item detail page with immersive cover and action sheet"
```

---

### Task 4: 安装到模拟器进行视觉验证

**Files:** N/A（验证步骤）

- [ ] **Step 1: 安装到模拟器**

```bash
xcrun simctl install "iPhone 16 Pro" build/Build/Products/Debug-iphonesimulator/Wherer.app
```

- [ ] **Step 2: 启动应用**

```bash
xcrun simctl launch "iPhone 16 Pro" com.kane.wherer
```

- [ ] **Step 3: 截图检查**

```bash
xcrun simctl io "iPhone 16 Pro" screenshot /Users/kane/Documents/workspace/claude/wherer/simulator_screenshots/item-detail-redesign.png
```

- [ ] **Step 4: 人工检查清单**

请用户验证：
- [ ] 封面图区域高度约 260pt，占满宽度
- [ ] 左上角返回按钮可见，点击可返回
- [ ] 右上角更多按钮可见，点击弹出 Action Sheet
- [ ] Action Sheet 包含"编辑物品""删除物品""取消"
- [ ] 标题和位置叠加在图片底部，白色文字
- [ ] 信息区 Label-Value 结构清晰，有分割线
- [ ] 标签显示为圆角胶囊
- [ ] 多张图片时有分页指示器（小圆点）
- [ ] 点击删除后弹出确认弹窗
- [ ] 编辑后保存，详情页正确刷新

---

## Self-Review

**1. Spec coverage:**
- ✅ 沉浸大图 260pt → Task 1 Step 2 `coverImageSection`
- ✅ 返回/更多毛玻璃按钮 → Task 1 Step 2 `backButton` / `moreButton`
- ✅ 标题叠加 → Task 1 Step 2 底部 `LinearGradient` + `VStack`
- ✅ Label-Value 信息区 → Task 2 Step 1-2 `infoSection` + `InfoRow`
- ✅ 分割线 → Task 2 Step 1 `Divider()`
- ✅ 圆角胶囊标签 → Task 2 Step 1 `HStack` with `cornerRadius(12)`
- ✅ Action Sheet（编辑/删除/取消）→ Task 1 Step 4 `confirmationDialog`
- ✅ 删除确认弹窗 → Task 3 Step 2 保留 `.alert`
- ✅ 分页指示器 → Task 1 Step 2 `TabView` + `.tabViewStyle(.page)`

**2. Placeholder scan:** 无 TBD/TODO/"implement later"/"appropriate error handling"

**3. Type consistency:**
- `ItemDetailView` 的 `@State` 名称在 plan 中与当前代码一致
- `InfoRow` 使用泛型 `Content: View`，与 SwiftUI 标准模式一致
- `confirmationDialog` 使用 iOS 15+ API，项目最低版本 16 兼容
