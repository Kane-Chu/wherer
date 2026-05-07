# Wherer 主题系统实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现 5 套主题切换 + 深浅模式选择 + 设置页面

**Architecture:** `ThemeManager` 作为 `ObservableObject` 通过 `EnvironmentObject` 注入根视图，提供 `effectiveColors` 和 `effectiveColorScheme`。视图通过 `@EnvironmentObject var themeManager: ThemeManager` 读取当前主题配色，替换原有的 `AppColors` 静态引用。

**Tech Stack:** SwiftUI, UserDefaults, Combine

---

## 文件结构

**新建文件：**
- `Models/AppearanceMode.swift` — 外观模式枚举（auto/light/dark）
- `Models/ThemeColors.swift` — 主题配色结构体
- `Models/Theme.swift` — 主题定义 + 5 套预置主题
- `ViewModels/ThemeManager.swift` — 主题管理器（持久化、响应式）
- `Views/Settings/SettingsView.swift` — 设置页面
- `Views/Settings/ThemePickerView.swift` — 主题选择网格

**修改文件：**
- `WhererApp.swift` — 初始化并注入 ThemeManager
- `ContentView.swift` — 新增「设置」Tab，应用 accentColor 和 colorScheme
- `SpaceListView.swift` — 替换 AppColors 引用
- `ItemListView.swift` — 替换 AppColors 引用
- `SpaceFormView.swift` — 替换背景和强调色
- `ItemFormView.swift` — 替换 AppColors 引用
- `SpaceDetailView.swift` — 替换标签 tint
- `ItemDetailView.swift` — 替换标签 tint
- `AppColors.swift` — 标记 deprecated

---

## Task 1: AppearanceMode 枚举

**Files:**
- Create: `Wherer/Models/AppearanceMode.swift`

- [ ] **Step 1: 编写枚举代码**

```swift
import Foundation

enum AppearanceMode: String, CaseIterable {
    case auto = "auto"
    case light = "light"
    case dark = "dark"

    var displayName: String {
        switch self {
        case .auto: return "自动"
        case .light: return "浅色"
        case .dark: return "深色"
        }
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add Wherer/Models/AppearanceMode.swift
git commit -m "feat: add AppearanceMode enum for theme system"
```

---

## Task 2: ThemeColors 结构体

**Files:**
- Create: `Wherer/Models/ThemeColors.swift`

- [ ] **Step 1: 编写结构体代码**

```swift
import SwiftUI

struct ThemeColors {
    let accent: Color
    let gradientStart: Color
    let gradientEnd: Color
    let background: Color
    let groupedBackground: Color
    let cardBackground: Color
    let tagTint: Color
    let tagTintOpacity: Double

    var primaryGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [gradientStart, gradientEnd]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add Wherer/Models/ThemeColors.swift
git commit -m "feat: add ThemeColors struct for theme system"
```

---

## Task 3: Theme 结构体 + 5 套预置主题

**Files:**
- Create: `Wherer/Models/Theme.swift`

- [ ] **Step 1: 编写完整 Theme 定义和 5 套主题**

```swift
import SwiftUI

struct Theme: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    let light: ThemeColors
    let dark: ThemeColors

    static let allThemes: [Theme] = [
        starry, sunset, mint, midnight, sakura
    ]

    static let defaultTheme = starry

    // MARK: - 1. 紫蓝星空
    static let starry = Theme(
        id: "starry",
        name: "紫蓝星空",
        icon: "sparkles",
        light: ThemeColors(
            accent: Color(hex: "#667eea"),
            gradientStart: Color(hex: "#667eea"),
            gradientEnd: Color(hex: "#764ba2"),
            background: Color(hex: "#ffffff"),
            groupedBackground: Color(hex: "#f2f2f7"),
            cardBackground: Color(hex: "#f8f9ff"),
            tagTint: Color(hex: "#667eea"),
            tagTintOpacity: 0.12
        ),
        dark: ThemeColors(
            accent: Color(hex: "#8b9cf0"),
            gradientStart: Color(hex: "#5a6fd6"),
            gradientEnd: Color(hex: "#8a6bc9"),
            background: Color(hex: "#000000"),
            groupedBackground: Color(hex: "#1c1c1e"),
            cardBackground: Color(hex: "#1a1d2e"),
            tagTint: Color(hex: "#8b9cf0"),
            tagTintOpacity: 0.18
        )
    )

    // MARK: - 2. 日落暖橙
    static let sunset = Theme(
        id: "sunset",
        name: "日落暖橙",
        icon: "sun.max.fill",
        light: ThemeColors(
            accent: Color(hex: "#ff7e5f"),
            gradientStart: Color(hex: "#ff7e5f"),
            gradientEnd: Color(hex: "#feb47b"),
            background: Color(hex: "#fffaf8"),
            groupedBackground: Color(hex: "#fff5f0"),
            cardBackground: Color(hex: "#ffffff"),
            tagTint: Color(hex: "#ff7e5f"),
            tagTintOpacity: 0.12
        ),
        dark: ThemeColors(
            accent: Color(hex: "#ff9a7e"),
            gradientStart: Color(hex: "#d66a4f"),
            gradientEnd: Color(hex: "#cc9468"),
            background: Color(hex: "#1a1410"),
            groupedBackground: Color(hex: "#241c18"),
            cardBackground: Color(hex: "#2d2420"),
            tagTint: Color(hex: "#ff9a7e"),
            tagTintOpacity: 0.18
        )
    )

    // MARK: - 3. 薄荷清新
    static let mint = Theme(
        id: "mint",
        name: "薄荷清新",
        icon: "leaf.fill",
        light: ThemeColors(
            accent: Color(hex: "#00b894"),
            gradientStart: Color(hex: "#00b894"),
            gradientEnd: Color(hex: "#00cec9"),
            background: Color(hex: "#f8fffd"),
            groupedBackground: Color(hex: "#f0faf7"),
            cardBackground: Color(hex: "#ffffff"),
            tagTint: Color(hex: "#00b894"),
            tagTintOpacity: 0.12
        ),
        dark: ThemeColors(
            accent: Color(hex: "#55efc4"),
            gradientStart: Color(hex: "#009973"),
            gradientEnd: Color(hex: "#00a8a3"),
            background: Color(hex: "#0f1a18"),
            groupedBackground: Color(hex: "#142420"),
            cardBackground: Color(hex: "#1a2e2b"),
            tagTint: Color(hex: "#55efc4"),
            tagTintOpacity: 0.18
        )
    )

    // MARK: - 4. 暗夜深邃
    static let midnight = Theme(
        id: "midnight",
        name: "暗夜深邃",
        icon: "moon.stars.fill",
        light: ThemeColors(
            accent: Color(hex: "#2c3e50"),
            gradientStart: Color(hex: "#2c3e50"),
            gradientEnd: Color(hex: "#34495e"),
            background: Color(hex: "#f0f2f5"),
            groupedBackground: Color(hex: "#e8eaed"),
            cardBackground: Color(hex: "#ffffff"),
            tagTint: Color(hex: "#2c3e50"),
            tagTintOpacity: 0.12
        ),
        dark: ThemeColors(
            accent: Color(hex: "#5d8aa8"),
            gradientStart: Color(hex: "#3a506b"),
            gradientEnd: Color(hex: "#5d8aa8"),
            background: Color(hex: "#0d1117"),
            groupedBackground: Color(hex: "#13171f"),
            cardBackground: Color(hex: "#161b22"),
            tagTint: Color(hex: "#5d8aa8"),
            tagTintOpacity: 0.18
        )
    )

    // MARK: - 5. 樱花粉嫩
    static let sakura = Theme(
        id: "sakura",
        name: "樱花粉嫩",
        icon: "flower.fill",
        light: ThemeColors(
            accent: Color(hex: "#ff6b9d"),
            gradientStart: Color(hex: "#ff6b9d"),
            gradientEnd: Color(hex: "#feca57"),
            background: Color(hex: "#fff8fb"),
            groupedBackground: Color(hex: "#fff0f5"),
            cardBackground: Color(hex: "#ffffff"),
            tagTint: Color(hex: "#ff6b9d"),
            tagTintOpacity: 0.12
        ),
        dark: ThemeColors(
            accent: Color(hex: "#ff8fb0"),
            gradientStart: Color(hex: "#d6597d"),
            gradientEnd: Color(hex: "#d4a84a"),
            background: Color(hex: "#1a1015"),
            groupedBackground: Color(hex: "#241820"),
            cardBackground: Color(hex: "#2d1c25"),
            tagTint: Color(hex: "#ff8fb0"),
            tagTintOpacity: 0.18
        )
    )
}
```

- [ ] **Step 2: Commit**

```bash
git add Wherer/Models/Theme.swift
git commit -m "feat: add Theme model with 5 presets"
```

---

## Task 4: ThemeManager

**Files:**
- Create: `Wherer/ViewModels/ThemeManager.swift`

- [ ] **Step 1: 编写 ThemeManager**

```swift
import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var currentTheme: Theme
    @Published var appearanceMode: AppearanceMode

    private var cancellables = Set<AnyCancellable>()

    static let allThemes = Theme.allThemes

    var effectiveColors: ThemeColors {
        let isDark: Bool
        switch appearanceMode {
        case .auto:
            isDark = UITraitCollection.current.userInterfaceStyle == .dark
        case .light:
            isDark = false
        case .dark:
            isDark = true
        }
        return isDark ? currentTheme.dark : currentTheme.light
    }

    var effectiveColorScheme: ColorScheme? {
        switch appearanceMode {
        case .auto: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    init() {
        let savedThemeId = UserDefaults.standard.string(forKey: "selectedThemeId")
        currentTheme = Theme.allThemes.first { $0.id == savedThemeId } ?? Theme.defaultTheme

        let savedMode = UserDefaults.standard.string(forKey: "appearanceMode")
        appearanceMode = AppearanceMode(rawValue: savedMode ?? "auto") ?? .auto

        $currentTheme
            .dropFirst()
            .sink { [weak self] _ in self?.save() }
            .store(in: &cancellables)

        $appearanceMode
            .dropFirst()
            .sink { [weak self] _ in self?.save() }
            .store(in: &cancellables)
    }

    func save() {
        UserDefaults.standard.set(currentTheme.id, forKey: "selectedThemeId")
        UserDefaults.standard.set(appearanceMode.rawValue, forKey: "appearanceMode")
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add Wherer/ViewModels/ThemeManager.swift
git commit -m "feat: add ThemeManager with persistence"
```

---

## Task 5: ThemePickerView

**Files:**
- Create: `Wherer/Views/Settings/ThemePickerView.swift`

- [ ] **Step 1: 创建 Settings 目录并编写 ThemePickerView**

```swift
import SwiftUI

struct ThemePickerView: View {
    @EnvironmentObject var themeManager: ThemeManager

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(ThemeManager.allThemes) { theme in
                ThemeCard(theme: theme, isSelected: themeManager.currentTheme.id == theme.id) {
                    themeManager.currentTheme = theme
                }
            }
        }
    }
}

struct ThemeCard: View {
    let theme: Theme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(theme.light.primaryGradient)
                        .frame(height: 80)
                        .overlay(
                            Image(systemName: theme.icon)
                                .font(.title2)
                                .foregroundColor(.white)
                        )

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.black.opacity(0.3)))
                            .padding(8)
                    }
                }

                Text(theme.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(.plain)
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add Wherer/Views/Settings/ThemePickerView.swift
git commit -m "feat: add ThemePickerView for theme selection"
```

---

## Task 6: SettingsView

**Files:**
- Create: `Wherer/Views/Settings/SettingsView.swift`

- [ ] **Step 1: 编写 SettingsView**

```swift
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("外观") {
                    ThemePickerView()
                        .padding(.vertical, 8)

                    Picker("深色模式", selection: $themeManager.appearanceMode) {
                        ForEach(AppearanceMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
        }
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add Wherer/Views/Settings/SettingsView.swift
git commit -m "feat: add SettingsView with theme and appearance mode pickers"
```

---

## Task 7: 修改 WhererApp.swift 注入 ThemeManager

**Files:**
- Modify: `Wherer/WhererApp.swift`

- [ ] **Step 1: 修改 WhererApp.swift**

将 `var body: some Scene` 修改为：

```swift
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView(context: persistenceController.container.viewContext)
                .environmentObject(themeManager)
        }
    }
```

完整文件：

```swift
import SwiftUI

@main
struct WhererApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var themeManager = ThemeManager()

    init() {
        UserDefaults.standard.set(["zh-Hans"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(context: persistenceController.container.viewContext)
                .environmentObject(themeManager)
        }
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add Wherer/WhererApp.swift
git commit -m "feat: inject ThemeManager into app root"
```

---

## Task 8: 修改 ContentView.swift 新增设置 Tab

**Files:**
- Modify: `Wherer/Views/ContentView.swift`

- [ ] **Step 1: 修改 ContentView.swift**

```swift
import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var spaceStore: SpaceStore
    @StateObject private var itemStore: ItemStore
    @EnvironmentObject var themeManager: ThemeManager

    init(context: NSManagedObjectContext) {
        let store = SpaceStore(context: context)
        _spaceStore = StateObject(wrappedValue: store)
        _itemStore = StateObject(wrappedValue: ItemStore(context: context))
    }

    var body: some View {
        TabView {
            SpaceListView()
                .tabItem {
                    Label("空间", systemImage: "house")
                }
                .environmentObject(spaceStore)
                .environmentObject(itemStore)

            ItemListView()
                .tabItem {
                    Label("物品", systemImage: "cube.box")
                }
                .environmentObject(spaceStore)
                .environmentObject(itemStore)

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape.fill")
                }
                .environmentObject(themeManager)
        }
        .accentColor(themeManager.effectiveColors.accent)
        .preferredColorScheme(themeManager.effectiveColorScheme)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add Wherer/Views/ContentView.swift
git commit -m "feat: add Settings tab and apply theme accent/colorScheme"
```

---

## Task 9: 修改 SpaceListView.swift 替换 AppColors

**Files:**
- Modify: `Wherer/Views/Spaces/SpaceListView.swift`

- [ ] **Step 1: 添加 themeManager 引用并替换按钮渐变**

在 `SpaceListView` 添加：

```swift
    @EnvironmentObject var themeManager: ThemeManager
```

将 toolbar 中的按钮 `ZStack` 里的 `.fill(AppColors.primaryGradient)` 替换为 `.fill(themeManager.effectiveColors.primaryGradient)`。

修改后的 `SpaceListView` 开头：

```swift
struct SpaceListView: View {
    @EnvironmentObject var spaceStore: SpaceStore
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingAddSpace = false
    @State private var editingSpace: Space?
    @State private var selectedItemID: ItemIdentifier?
    @State private var searchQuery = ""
```

修改 toolbar 按钮（第 64 行附近）：

```swift
                        ZStack {
                            Circle()
                                .fill(themeManager.effectiveColors.primaryGradient)
                                .frame(width: 36, height: 36)
                            Image(systemName: "plus")
                                .font(.title3.weight(.semibold))
                                .foregroundColor(.white)
                        }
```

- [ ] **Step 2: Commit**

```bash
git add Wherer/Views/Spaces/SpaceListView.swift
git commit -m "feat: apply theme colors to SpaceListView"
```

---

## Task 10: 修改 ItemListView.swift 替换 AppColors

**Files:**
- Modify: `Wherer/Views/Items/ItemListView.swift`

- [ ] **Step 1: 添加 themeManager 引用并替换按钮渐变**

在 `ItemListView` 添加：

```swift
    @EnvironmentObject var themeManager: ThemeManager
```

将 toolbar 中的按钮 `.fill(AppColors.primaryGradient)` 替换为 `.fill(themeManager.effectiveColors.primaryGradient)`。

修改后的 `ItemListView` 开头：

```swift
struct ItemListView: View {
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var spaceStore: SpaceStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var searchQuery = ""
    @State private var selectedItemID: ItemIdentifier?
    @State private var showingAddItem = false
```

修改 toolbar 按钮（第 42 行附近）：

```swift
                        ZStack {
                            Circle()
                                .fill(themeManager.effectiveColors.primaryGradient)
                                .frame(width: 36, height: 36)
                            Image(systemName: "plus")
                                .font(.title3.weight(.semibold))
                                .foregroundColor(.white)
                        }
```

- [ ] **Step 2: Commit**

```bash
git add Wherer/Views/Items/ItemListView.swift
git commit -m "feat: apply theme colors to ItemListView"
```

---

## Task 11: 修改 SpaceFormView.swift 应用主题

**Files:**
- Modify: `Wherer/Views/Spaces/SpaceFormView.swift`

- [ ] **Step 1: 添加 themeManager 并应用背景色**

在 `SpaceFormView` 添加：

```swift
    @EnvironmentObject var themeManager: ThemeManager
```

修改后的 `SpaceFormView` 开头：

```swift
struct SpaceFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var spaceStore: SpaceStore
    @EnvironmentObject var themeManager: ThemeManager
```

在 `body` 的 `NavigationStack` 前添加背景色：

```swift
    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.effectiveColors.groupedBackground
                    .ignoresSafeArea()
                Form {
                    ...
                }
            }
            ...
        }
    }
```

注意：`Form` 在 iOS 16+ 会自带背景，这里通过外层 `ZStack` 设置背景色可能在某些 iOS 版本下效果不佳。更简单的方式是保持 `Form` 原生样式，由 `ContentView` 的 `.preferredColorScheme` 控制系统深浅模式即可。如果确实需要自定义 Form 背景，在 iOS 16+ 可用 `.scrollContentBackground(.hidden)` + `.background(...)`。

**建议简化：** 不修改 `SpaceFormView` 背景色，仅由系统 colorScheme 控制。如果后续测试发现 Form 背景与主题不搭，再单独处理。

因此实际修改：**不修改 SpaceFormView**，跳过此任务。Form 背景由系统 colorScheme 自动适配。

- [ ] **Step 2: 记录跳过原因**

SpaceFormView 使用 `Form`，其背景由系统 `colorScheme` 自动管理（`groupedBackground` 自动深浅切换）。`ContentView` 已设置 `.preferredColorScheme(themeManager.effectiveColorScheme)`，因此 Form 背景会自动跟随。无需额外修改。

---

## Task 12: 修改 ItemFormView.swift 替换 AppColors

**Files:**
- Modify: `Wherer/Views/Shared/ItemFormView.swift`

- [ ] **Step 1: 添加 themeManager 引用并替换所有 AppColors 引用**

在 `ItemFormView` 添加：

```swift
    @EnvironmentObject var themeManager: ThemeManager
```

修改后的 `ItemFormView` 开头：

```swift
struct ItemFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var spaceStore: SpaceStore
    @EnvironmentObject var themeManager: ThemeManager
```

**替换 1：** 第 29 行的 `Color(.systemGroupedBackground)` 替换为 `themeManager.effectiveColors.groupedBackground`：

```swift
                themeManager.effectiveColors.groupedBackground
                    .ignoresSafeArea()
```

**替换 2：** 第 149-150 行的 tag 背景色：

```swift
                                .background(themeManager.effectiveColors.tagTint.opacity(themeManager.effectiveColors.tagTintOpacity))
                                .foregroundColor(themeManager.effectiveColors.accent)
```

**替换 3：** 第 158 行的 `Color(.systemBackground)` 替换为 `themeManager.effectiveColors.cardBackground`：

```swift
        .background(themeManager.effectiveColors.cardBackground)
```

**替换 4：** 第 182 行的删除卡片背景：

```swift
                        .background(themeManager.effectiveColors.cardBackground)
```

**替换 5：** 第 200 行的 photoCard 背景：

```swift
        .background(themeManager.effectiveColors.cardBackground)
```

**替换 6：** 第 216-217 行的「封面」标签：

```swift
                    .background(themeManager.effectiveColors.accent)
```

**替换 7：** 第 240 行的选择对勾颜色：

```swift
                                .foregroundColor(themeManager.effectiveColors.accent)
```

**替换 8：** 第 268 行的选择对勾颜色：

```swift
                                    .foregroundColor(themeManager.effectiveColors.accent)
```

**替换 9：** 第 401 行的拍照按钮渐变：

```swift
        .background(themeManager.effectiveColors.primaryGradient)
```

**替换 10：** 第 430 行的封面选中边框：

```swift
                                    .stroke(coverIndex == index ? themeManager.effectiveColors.accent : Color.clear, lineWidth: 3)
```

- [ ] **Step 2: Commit**

```bash
git add Wherer/Views/Shared/ItemFormView.swift
git commit -m "feat: apply theme colors to ItemFormView"
```

---

## Task 13: 修改 SpaceDetailView.swift 替换标签 tint

**Files:**
- Modify: `Wherer/Views/Spaces/SpaceDetailView.swift`

- [ ] **Step 1: 添加 themeManager 并替换 tag tint**

在 `SpaceDetailView` 添加：

```swift
    @EnvironmentObject var themeManager: ThemeManager
```

在 `SpaceDetailItemRowView` 添加：

```swift
    @EnvironmentObject var themeManager: ThemeManager
```

将 tag 的背景色和前景色替换（第 82-83 行）：

```swift
                            .background(themeManager.effectiveColors.tagTint.opacity(themeManager.effectiveColors.tagTintOpacity))
                            .foregroundColor(themeManager.effectiveColors.accent)
```

- [ ] **Step 2: Commit**

```bash
git add Wherer/Views/Spaces/SpaceDetailView.swift
git commit -m "feat: apply theme colors to SpaceDetailView"
```

---

## Task 14: 修改 ItemDetailView.swift 替换标签 tint

**Files:**
- Modify: `Wherer/Views/Shared/ItemDetailView.swift`

- [ ] **Step 1: 添加 themeManager 并替换 tag tint**

在 `ItemDetailView` 添加：

```swift
    @EnvironmentObject var themeManager: ThemeManager
```

将 infoSection 中的 tag 背景和前景色替换（第 145-146 行）：

```swift
                                .background(themeManager.effectiveColors.tagTint.opacity(themeManager.effectiveColors.tagTintOpacity))
                                .foregroundColor(themeManager.effectiveColors.accent)
```

- [ ] **Step 2: Commit**

```bash
git add Wherer/Views/Shared/ItemDetailView.swift
git commit -m "feat: apply theme colors to ItemDetailView"
```

---

## Task 15: 修改 AppColors.swift 标记 deprecated

**Files:**
- Modify: `Wherer/Models/AppColors.swift`

- [ ] **Step 1: 添加 @available 标记**

```swift
import SwiftUI

@available(*, deprecated, message: "Use ThemeManager.effectiveColors instead")
enum AppColors {
    static let primaryGradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "#667eea"), Color(hex: "#764ba2")]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accent = Color(hex: "#667eea")
}
```

- [ ] **Step 2: Commit**

```bash
git add Wherer/Models/AppColors.swift
git commit -m "chore: mark AppColors as deprecated in favor of ThemeManager"
```

---

## Task 16: 构建验证

- [ ] **Step 1: 编译项目**

```bash
xcodebuild -project Wherer.xcodeproj -scheme Wherer -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Expected: BUILD SUCCEEDED

- [ ] **Step 2: 手动测试清单**

在模拟器中运行，逐项验证：

1. **设置 Tab 存在**：底部 TabBar 有「设置」Tab，图标为齿轮
2. **主题选择器显示**：进入设置页，看到 5 个主题卡片，当前主题有对勾
3. **切换主题**：点击「日落暖橙」，整个 App 的强调色变为橙色（TabBar 选中色、按钮等）
4. **深浅模式跟随系统**：外观模式选「自动」，切换模拟器系统深浅色模式，App 跟随变化
5. **强制浅色**：选「浅色」，即使系统为深色，App 也保持浅色
6. **强制深色**：选「深色」，即使系统为浅色，App 也保持深色
7. **表单页面**：进入添加物品页面，标签预览底色和文字色跟随主题
8. **物品详情**：标签底色和文字色跟随主题
9. **持久化**：杀掉 App 重新打开，上次选择的主题和模式仍然保留
10. **升级兼容**：清除 UserDefaults 后启动，使用默认主题（紫蓝星空）+ 自动模式

- [ ] **Step 3: Commit（如修复了编译问题）**

如有修复，commit：

```bash
git commit -m "fix: resolve theme integration issues"
```

---

## Self-Review

### Spec Coverage

| Spec 需求 | 实现任务 |
|-----------|----------|
| AppearanceMode 枚举 | Task 1 |
| ThemeColors 结构体 | Task 2 |
| Theme 结构体 + 5 套主题 | Task 3 |
| ThemeManager（持久化、effectiveColors、effectiveColorScheme） | Task 4 |
| ThemePickerView | Task 5 |
| SettingsView（主题 + 外观模式 + 关于） | Task 6 |
| WhererApp 注入 ThemeManager | Task 7 |
| ContentView 新增设置 Tab + accentColor + colorScheme | Task 8 |
| 替换所有 AppColors 引用 | Task 9-14 |
| AppColors 标记 deprecated | Task 15 |
| 构建 + 手动测试 | Task 16 |

### Placeholder Scan

- 无 TBD、TODO
- 所有步骤含完整代码或明确命令
- 无模糊描述

### Type Consistency

- `ThemeManager.effectiveColors` 返回 `ThemeColors` — 所有消费处一致使用
- `ThemeManager.effectiveColorScheme` 返回 `ColorScheme?` — ContentView 使用 `.preferredColorScheme(...)` 接收
- `tagTintOpacity: Double` — 消费处统一使用 `.opacity(themeManager.effectiveColors.tagTintOpacity)`

### 已知问题与决策

1. **SpaceFormView 背景色**：`Form` 背景由系统 `colorScheme` 自动管理，未强制替换为自定义色。若测试发现视觉不协调，可在 Form 上添加 `.scrollContentBackground(.hidden)` + `.background(...)` 处理。
2. **ThemeManager.auto 模式检测**：使用 `UITraitCollection.current.userInterfaceStyle`，在 `.onAppear` 后或视图层级中读取更准确。若发现切换系统模式时 auto 不跟随，可改用 `@Environment(\.colorScheme)` 在视图中检测。
3. **ItemDetailView 封面区域**：封面使用固定渐变遮罩（`.black.opacity(...)`），不受主题影响，这是预期行为。
