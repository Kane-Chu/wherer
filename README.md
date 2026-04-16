# Wherer

> 你的私人物品收纳管家 —— 记录每一件物品的位置，告别找不到东西的烦恼。

## 简介

**Wherer**（放哪了）是一款专为 iPhone 设计的物品管理应用。通过空间分类、拍照记录和快速搜索，帮你轻松管理家中或办公室的各类物品。无论是换季衣物、电子设备还是重要文件，打开 Wherer 就能知道它"放哪了"。

## 功能特性

- **空间管理**：支持卧室、书房、客厅、储物间等多种空间分类，自定义颜色和图标
- **物品记录**：添加物品名称、位置、类型和标签，支持多张照片上传
- **封面设置**：为多张物品照片设置封面，物品列表展示更直观
- **图片预览**：点击照片进入全屏预览，支持捏合缩放和双击放大
- **快速搜索**：通过名称、位置或标签快速定位物品
- **按空间浏览**：进入空间详情页，查看该空间下的所有物品
- **最近添加**：首页展示最新添加的物品，方便快速回顾

## 技术栈

- **语言**：Swift 5
- **框架**：SwiftUI
- **数据持久化**：Core Data + CloudKit（本地优先，支持 iCloud 同步）
- **最低系统版本**：iOS 17.0
- **构建工具**：Xcode + `project.yml`（XcodeGen）

## 项目结构

```
Wherer/
├── Models/              # 数据模型（Space、Item、Category 等）
├── ViewModels/          # 状态管理（SpaceStore、ItemStore）
├── Views/               # SwiftUI 视图
│   ├── Spaces/          # 空间相关页面
│   ├── Items/           # 物品相关页面
│   ├── Shared/          # 通用组件（搜索栏、表单、图片预览等）
│   └── Components/      # 首页组件（最近添加）
├── Services/            # 业务服务（PhotoService、SearchService）
├── Persistence/         # Core Data 模型和持久化配置
├── Preview Content/     # 预览资源
└── WhererApp.swift      # 应用入口

WhererTests/             # 单元测试
```

## 本地运行

1. 克隆仓库到本地
2. 使用 Xcode 15+ 打开 `Wherer.xcodeproj`
3. 选择目标设备或模拟器（iOS 17.0+）
4. 点击 `Cmd + R` 编译并运行

> 提示：项目使用 `project.yml` 管理 Xcode 工程配置。如需重新生成 `.xcodeproj`，请确保已安装 [XcodeGen](https://github.com/yonaskolb/XcodeGen)，然后执行 `xcodegen generate`。

## 版本历史

### v1.0.0 (2026-04-17)
- Wherer MVP 正式发布
- 支持空间管理、物品增删改查、拍照/相册上传、封面设置、图片预览和搜索

## 设计稿

项目初期的原型设计和线框图可参考仓库根目录下的 `wireframe.html` 及 `wireframe_*.png`。

## 开源协议

MIT License
