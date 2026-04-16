# Wherer（放哪了）App 设计文档

## 1. 项目概述

**Wherer（放哪了）** 是一款帮助用户记录和查找物品存放位置的 iOS 应用。生活中的物品常常找不到——换季衣服、证件、药品、数码设备等。通过这款 App，用户可以快速记录物品的存放位置，配合照片和分类，在需要时秒速找到。

### 核心价值
- **简单**：打开 App，几步完成记录
- **美观**：现代 iOS 设计风格，界面清爽
- **流畅**：原生体验，动画顺滑
- **友好**：不用学习，直观上手

---

## 2. 技术选型

| 维度 | 选择 | 说明 |
|------|------|------|
| 开发语言 | Swift + SwiftUI | 原生 iOS 技术栈，性能最好，界面最流畅 |
| 数据持久化 | Core Data | 苹果官方推荐，稳定成熟 |
| 数据同步 | CloudKit | 同一 Apple ID 设备自动同步，用户无感知 |
| 照片存储 | 本地文件系统 + iCloud 容器 | 与 Core Data 记录关联 |
| 最低系统版本 | iOS 16+ | 覆盖绝大多数活跃设备 |

---

## 3. MVP 功能范围

### 3.1 核心功能（第一阶段）
1. **空间管理**
   - 预置常用空间：卧室、书房、客厅、储物间
   - 支持用户自定义添加新空间
   - 每个空间显示物品数量

2. **物品记录**
   - 物品名称
   - 具体存放位置（文字描述，如"书柜第二层抽屉"）
   - 所属空间
   - 照片（支持拍照或从相册选择）
   - 标签（可选，逗号分隔）

3. **双视图浏览**
   - **空间视图**：以卡片网格展示各空间，点击进入空间详情查看物品列表
   - **物品视图**：按物品类型分组展示（衣服、证件、药品、数码、其他）

4. **搜索**
   - 全局搜索栏，支持按物品名称、位置、标签搜索
   - 实时过滤结果

5. **最近添加**
   - 首页展示最近添加的 5 个物品，方便快速回溯

### 3.2 后续扩展（第二阶段）
- iOS 小组件（快速搜索/最新物品）
- Siri / 快捷指令支持（"我的相机放哪了"）
- 到期提醒（"半年后提醒我换季衣服在哪"）
- 家人共享（通过 iCloud 共享数据库）

---

## 4. 界面设计

### 4.1 页面结构

```
├── Tab: 空间
│   └── 首页（空间网格 + 最近添加）
│       └── 空间详情页（该空间下的物品列表）
├── Tab: 物品
│   └── 物品视图（按类型分组卡片网格）
│       └── 物品详情页（查看/编辑）
└── 添加物品页（模态弹窗或导航页）
```

### 4.2 视觉风格

- **整体风格**：iOS 原生风格，圆角卡片，大留白，清晰层次
- **主色调**：紫蓝渐变（#667eea → #764ba2），用于主按钮、选中状态、标签
- **空间卡片配色**：
  - 卧室：暖橙黄渐变（#ffeaa7 → #fab1a0）
  - 书房：青粉渐变（#a8edea → #fed6e3）
  - 客厅：紫粉渐变（#d299c2 → #fef9d7）
  - 储物间：天蓝渐变（#89f7fe → #66a6ff）
- **字体**：系统默认字体，标题加粗，辅助信息灰色

### 4.3 底部导航栏

- **空间 Tab**：🏠 空间（默认页）
- **物品 Tab**：📦 物品
- 当前选中项使用主色调高亮

---

## 5. 数据模型

### 5.1 Space（空间）
```swift
struct Space {
    let id: UUID
    var name: String          // 空间名称，如"书房"
    var icon: String          // 图标 emoji 或 SF Symbol 名称
    var colorHex: String      // 卡片背景色，存储为十六进制
    var createdAt: Date
    var items: [Item]         // 关联物品
}
```

### 5.2 Item（物品）
```swift
struct Item {
    let id: UUID
    var name: String          // 物品名称
    var location: String      // 具体存放位置
    var spaceID: UUID         // 所属空间
    var category: Category    // 物品类型枚举
    var tags: [String]        // 标签数组
    var photoFilename: String? // 照片文件名（本地存储）
    var createdAt: Date
    var updatedAt: Date
}
```

### 5.3 Category（物品类型枚举）
```swift
enum Category: String, CaseIterable {
    case clothing = "衣服"
    case document = "证件"
    case medicine = "药品"
    case electronics = "数码"
    case other = "其他"
}
```

---

## 6. 架构设计

### 6.1 整体架构
采用 SwiftUI 推荐的 MVVM 模式：

- **Model**：Core Data 实体定义
- **ViewModel**：`SpaceStore`、`ItemStore` 等 ObservableObject，负责数据操作和状态管理
- **View**：SwiftUI 视图，响应式绑定 ViewModel
- **Service**：`PhotoService`（照片存取）、`SearchService`（搜索过滤）

### 6.2 数据流
1. 用户操作触发 View 事件
2. ViewModel 调用 Core Data 进行 CRUD
3. Core Data 自动同步到 CloudKit
4. ViewModel 发布状态变更，SwiftUI 自动刷新界面

### 6.3 照片存储策略
- 照片保存在 App 的 `Documents/Photos/` 目录下
- 文件命名：`{itemID}.jpg`
- Core Data 只存储文件名，不存二进制数据
- 享受 iCloud 备份和 Core Data 记录同步

---

## 7. 核心交互流程

### 7.1 添加物品
1. 点击右上角 "+" 按钮
2. 进入添加页面，可选拍照/选图
3. 填写名称、位置、选择空间、添加标签
4. 点击保存，返回首页

### 7.2 查找物品
1. 在首页搜索栏输入关键词
2. 实时显示匹配结果
3. 或切换到"空间"Tab 浏览空间卡片
4. 或切换到"物品"Tab 按类型查找

### 7.3 编辑/删除物品
1. 在空间详情或物品视图中点击物品
2. 进入物品详情页
3. 支持编辑信息和删除

---

## 8. 非功能性要求

- **性能**：列表滑动 60fps，搜索响应 < 100ms
- **离线可用**：所有核心功能无需网络
- **隐私**：数据存储在用户设备和 iCloud 中，不上传到第三方服务器
- **可访问性**：支持 VoiceOver、Dynamic Type

---

## 9. 开发阶段规划

### 第一阶段：MVP（当前 Spec）
- 项目搭建 + Core Data 配置
- 空间视图 + 物品视图 + 底部导航
- 添加/编辑/删除物品
- 拍照 + 相册选图
- 搜索功能
- CloudKit 同步

### 第二阶段：增强体验
- iOS 小组件
- Siri 快捷指令
- 到期提醒（本地通知）
- 数据导入导出

---

## 10. 设计草图

界面流程草图已保存至：`/Users/kane/Documents/workspace/claude/wherer/wireframe.html`

包含三个核心页面：
- 首页：空间视图
- 物品视图：按类型分组
- 添加物品页
