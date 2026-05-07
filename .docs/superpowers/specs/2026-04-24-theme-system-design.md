# Wherer 主题系统设计文档

## 背景

当前 App 使用固定配色（`AppColors` 中的紫蓝渐变），无主题切换能力，无设置页面。用户希望可以自由选择主题，并支持浅色/深色模式切换。

## 目标

1. 新增 5 套精心设计的主题，每套包含浅色/深色两套配色
2. 支持「跟随系统 / 强制浅色 / 强制深色」三种外观模式
3. 新增「设置」Tab，包含主题选择和外观模式切换
4. 主题切换实时生效，无需重启 App

## 非目标

- 不支持用户自定义主题颜色
- 不替换空间级别的 `ColorPreset` 系统（空间渐变保持不变）
- 不修改物品分类颜色（`Category` 颜色保持不变）

## 数据模型

### Theme

```swift
struct Theme: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    let light: ThemeColors
    let dark: ThemeColors
}
```

### ThemeColors

```swift
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

### AppearanceMode

```swift
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

## 5 套主题配色

### 1. 紫蓝星空（starry）

| 模式 | accent | gradientStart | gradientEnd | background | groupedBackground | cardBackground | tagTint (color / opacity) |
|------|--------|---------------|-------------|------------|-------------------|----------------|---------|
| 浅色 | `#667eea` | `#667eea` | `#764ba2` | `#ffffff` | `#f2f2f7` | `#f8f9ff` | `#667eea` / 0.12 |
| 深色 | `#8b9cf0` | `#5a6fd6` | `#8a6bc9` | `#000000` | `#1c1c1e` | `#1a1d2e` | `#8b9cf0` / 0.18 |

### 2. 日落暖橙（sunset）

| 模式 | accent | gradientStart | gradientEnd | background | groupedBackground | cardBackground | tagTint (color / opacity) |
|------|--------|---------------|-------------|------------|-------------------|----------------|---------|
| 浅色 | `#ff7e5f` | `#ff7e5f` | `#feb47b` | `#fffaf8` | `#fff5f0` | `#ffffff` | `#ff7e5f` / 0.12 |
| 深色 | `#ff9a7e` | `#d66a4f` | `#cc9468` | `#1a1410` | `#241c18` | `#2d2420` | `#ff9a7e` / 0.18 |

### 3. 薄荷清新（mint）

| 模式 | accent | gradientStart | gradientEnd | background | groupedBackground | cardBackground | tagTint (color / opacity) |
|------|--------|---------------|-------------|------------|-------------------|----------------|---------|
| 浅色 | `#00b894` | `#00b894` | `#00cec9` | `#f8fffd` | `#f0faf7` | `#ffffff` | `#00b894` / 0.12 |
| 深色 | `#55efc4` | `#009973` | `#00a8a3` | `#0f1a18` | `#142420` | `#1a2e2b` | `#55efc4` / 0.18 |

### 4. 暗夜深邃（midnight）

| 模式 | accent | gradientStart | gradientEnd | background | groupedBackground | cardBackground | tagTint (color / opacity) |
|------|--------|---------------|-------------|------------|-------------------|----------------|---------|
| 浅色 | `#2c3e50` | `#2c3e50` | `#34495e` | `#f0f2f5` | `#e8eaed` | `#ffffff` | `#2c3e50` / 0.12 |
| 深色 | `#5d8aa8` | `#3a506b` | `#5d8aa8` | `#0d1117` | `#13171f` | `#161b22` | `#5d8aa8` / 0.18 |

### 5. 樱花粉嫩（sakura）

| 模式 | accent | gradientStart | gradientEnd | background | groupedBackground | cardBackground | tagTint (color / opacity) |
|------|--------|---------------|-------------|------------|-------------------|----------------|---------|
| 浅色 | `#ff6b9d` | `#ff6b9d` | `#feca57` | `#fff8fb` | `#fff0f5` | `#ffffff` | `#ff6b9d` / 0.12 |
| 深色 | `#ff8fb0` | `#d6597d` | `#d4a84a` | `#1a1015` | `#241820` | `#2d1c25` | `#ff8fb0` / 0.18 |

## ThemeManager

```swift
class ThemeManager: ObservableObject {
    @Published var currentTheme: Theme
    @Published var appearanceMode: AppearanceMode
    
    private var cancellables = Set<AnyCancellable>()
    
    static let allThemes: [Theme] = [...]
    
    var effectiveColors: ThemeColors {
        let isDark = ... // 根据 appearanceMode + 系统 colorScheme 计算
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
        // 从 UserDefaults 加载，无记录则用默认主题
    }
    
    func save() {
        UserDefaults.standard.set(currentTheme.id, forKey: "selectedThemeId")
        UserDefaults.standard.set(appearanceMode.rawValue, forKey: "appearanceMode")
    }
}
```

**关键点：**
- `effectiveColors` 自动根据 `appearanceMode` + 系统 `colorScheme` 决定实际使用的配色
- `effectiveColorScheme` 返回 `ColorScheme?`，用于根视图的 `.preferredColorScheme()`
- `save()` 只存主题 ID 和模式字符串
- 初始化时自动 `load()`

## 设置页面

### SettingsView

新增为 TabView 第三个 Tab，图标 `gearshape.fill`，标题「设置」。

页面结构：
- **Section：外观**
  - ThemePickerView（主题选择网格）
  - AppearanceModePicker（分段选择器：自动 / 浅色 / 深色）
- **Section：关于**
  - 版本号（读取 CFBundleShortVersionString）
  - 应用名称

### ThemePickerView

- 网格布局，每行 2 个（iPhone）或 3 个（iPad）
- 每个主题卡片：
  - 圆角矩形（R: 16）
  - 背景用该主题的 `primaryGradient`
  - 卡片中心显示主题 `icon`（白色）
  - 卡片下方显示主题名
  - 当前选中卡片带白色对勾（`checkmark.circle.fill`）叠加在右上角
- 点击卡片即切换主题，实时生效

## 集成点

需要修改的文件及变更内容：

| 文件 | 变更 |
|------|------|
| `WhererApp.swift` | 初始化 `ThemeManager`，注入到 `ContentView` |
| `ContentView.swift` | 接收 `ThemeManager`，设置 `.accentColor()` 和 `.preferredColorScheme()`，新增「设置」Tab |
| `SpaceListView.swift` | 替换 `AppColors.accent` / `AppColors.primaryGradient`，替换背景色 |
| `ItemListView.swift` | 同上 |
| `SpaceFormView.swift` | 替换表单背景色、按钮渐变 |
| `ItemFormView.swift` | 同上 |
| `SpaceDetailView.swift` | 替换背景色、标签底色 |
| `ItemDetailView.swift` | 替换背景色、标签底色 |
| `SpaceCardView.swift` | 如有系统背景色则替换 |
| `AppColors.swift` | 标记为 deprecated，引导使用 ThemeManager |

**新建文件：**
- `Models/Theme.swift`
- `Models/ThemeColors.swift`
- `Models/AppearanceMode.swift`
- `ViewModels/ThemeManager.swift`
- `Views/Settings/SettingsView.swift`
- `Views/Settings/ThemePickerView.swift`

## 边界情况

- 系统从浅色切换到深色时，如果模式是「自动」，App 自动跟随切换
- 从旧版本升级的用户：无 UserDefaults 记录，使用默认主题（紫蓝星空）+ 自动模式
- 空间原有的 `ColorPreset` 渐变不受主题系统影响，保持独立

## 不做的

- 不使用 `Assets.xcassets` 颜色集（不支持渐变，动态切换体验差）
- 不修改 `ColorPreset` 系统
- 不修改 `Category` 颜色
