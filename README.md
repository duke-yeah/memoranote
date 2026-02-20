# Memora - 极光科技记事本

<div align="center">

**一款现代化 macOS 记事本应用，采用橙紫科技配色方案，支持语音录入**

[![macOS](https://img.shields.io/badge/macOS-14.0+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-green.svg)](https://developer.apple.com/xcode/swiftui/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

</div>

---

## ✨ 功能特性

### 核心功能

- 📝 **多任务清单** - 每个记事支持多个可独立勾选的任务项
- 🎯 **优先级管理** - 高/中/低三级优先级，用不同颜色标识
- ⏰ **时间筛选** - 支持按"今天/最近7天/最近30天"筛选记事
- 🔍 **实时搜索** - 快速搜索标题和内容
- 📊 **进度追踪** - 实时显示任务完成进度（如：75% [3/4]）
- 🎨 **橙紫主题** - 橙色文字 + 紫色结构层次，科技感深色界面
- 🎙️ **语音录入** - 支持实时语音转文字并自动创建记事（含优先级/时间解析）

### 设计亮点

- 🌙 **深色主题** - 深邃黑色背景，专注沉浸式体验
- 🟠 **橙紫配色** - 橙色信息强调 + 紫色视觉结构，现代科技感
- 🔷 **简洁图标** - 现代化的勾选框图标设计
- ⚡ **流畅动画** - 丝滑的交互体验
- 🔐 **本地存储** - 使用 SwiftData 本地存储，隐私安全

---

## 📸 截图

> 注：如需添加应用截图，可在此处插入

---

## 🚀 快速开始

### 系统要求

- macOS 14.0 (Sonoma) 或更高版本
- Xcode 15+ (仅开发需要)

### 下载安装

#### 方法 1: 下载预编译版本（推荐）

1. 前往 [Releases](https://github.com/duke-yeah/memoranote/releases) 页面
2. 下载最新版本的 `Memora分享版.zip`
3. 解压后将 `Memora.app` 拖到「应用程序」文件夹
4. **首次打开**：右键点击 → 选择「打开」→ 在弹出对话框中点击「打开」
5. 以后就可以正常双击打开了

> ⚠️ **安全提示**：因为应用没有 Apple 开发者签名，首次打开需要手动允许。应用完全安全，只是因为是个人开发项目。

#### 方法 2: 从源码编译

```bash
# 1. 克隆仓库
git clone https://github.com/duke-yeah/memoranote.git
cd memoranote

# 2. 在 Xcode 中打开
open Memora.xcodeproj

# 3. 运行项目 (⌘R)
```

#### 方法 3: 使用自动安装脚本

```bash
# 克隆仓库后运行安装脚本
./install_memora.sh
```

---

## 💡 使用指南

### 创建记事

1. 点击右上角 **「+」** 按钮
2. 输入标题和内容
3. 点击 **「+ 添加清单项」** 来添加任务项
4. 选择优先级（高/中/低）
5. 点击 **「保存」**

### 语音创建记事

1. 点击工具栏的 **麦克风按钮**
2. 开始说话，实时查看转写结果
3. 点击 **「SAVE NOTE」** 自动生成记事
4. 语音文本会自动解析优先级和时间关键词（如“明天”“紧急”）

### 勾选任务

- 在列表中直接点击任务项前的**勾选框**即可切换完成状态
- 在详情页也可以勾选任务

### 查看进度

- 每个记事卡片右上角显示完成进度，例如：**75% [3/4]**
- 绿色圆环表示进度百分比

### 筛选记事

点击工具栏的**筛选按钮**（漏斗图标），可以：

- **按优先级筛选** - 高/中/低/全部
- **按时间筛选** - 今天/最近7天/最近30天/全部
- **组合筛选** - 时间 + 优先级 + 搜索

### 编辑和删除

- **编辑**：点击记事 → 右上角菜单 → 编辑
- **删除**：在列表中左滑记事卡片 → 删除

---

## 🛠️ 技术栈

- **语言**: Swift 5.9+
- **框架**: SwiftUI
- **语音能力**: Speech + AVFoundation
- **数据持久化**: SwiftData (iOS 17+ / macOS 14+)
- **架构**: MVVM-lite + Repository Pattern
- **设计系统**: 自定义 DesignSystem (极光科技主题)

### 项目结构

```
Memora/
├── App/
│   └── MemoraApp.swift          # 应用入口
├── Models/
│   ├── Note.swift               # 记事数据模型
│   ├── ChecklistItem.swift      # 清单项模型
│   └── NotePriority.swift       # 优先级枚举
├── Views/
│   ├── Notes/
│   │   ├── NoteListView.swift   # 记事列表（含时间筛选）
│   │   ├── NoteDetailView.swift # 记事详情
│   │   ├── NoteEditorView.swift # 记事编辑器
│   │   └── NoteRowView.swift    # 记事行组件
│   └── Components/
│       └── PriorityBadge.swift  # 优先级徽章
├── Services/
│   └── NoteRepository.swift     # 数据访问层
└── Design/
    └── DesignSystem.swift       # EVA 主题设计系统
```

### 核心特性实现

#### SwiftData 数据模型

```swift
@Model
final class Note {
    var id: UUID
    var title: String
    var content: String
    var priority: NotePriority
    var completed: Bool
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade)
    var items: [ChecklistItem]
}
```

#### 时间筛选功能

```swift
enum TimeFilter: String, CaseIterable {
    case all = "全部"
    case today = "今天"
    case week = "最近7天"
    case month = "最近30天"

    var startDate: Date? {
        // 根据选项计算起始日期
    }
}
```

#### 极光科技配色

```swift
struct DesignSystem {
    struct Colors {
        static let primary = Color(hex: "#8B5CF6")      // 极光紫
        static let secondary = Color(hex: "#6D28D9")    // 深紫
        static let accent = Color(hex: "#F97316")       // 活力橙
        static let background = Color(hex: "#0A0A0F")   // 深邃黑
    }
}
```

---

## 📚 文档

- [时间筛选功能说明](TIME_FILTER_FEATURE.md)
- [安装指南](INSTALLATION_GUIDE.md)
- [分享指南](SHARE_GUIDE.md)
- [主题升级指南](UPGRADE_GUIDE.md)
- [图标设计指南](EVA_ICON_DESIGN.md)

---

## 🎯 开发路线图

- [x] 基础记事功能
- [x] 多任务清单
- [x] 优先级管理
- [x] 极光紫主题设计
- [x] 时间筛选功能
- [x] 实时搜索
- [ ] iCloud 同步
- [ ] 标签系统
- [ ] 提醒功能
- [ ] Markdown 支持
- [ ] 多主题切换
- [ ] iOS 版本

---

## 🤝 贡献

欢迎贡献代码、报告问题或提出新功能建议！

1. Fork 本仓库
2. 创建你的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交你的修改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启一个 Pull Request

---

## 📝 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

---

## 🙏 致谢

- 感谢 Apple 提供的 SwiftUI 和 SwiftData 框架

---

## 📧 联系方式

如有问题或建议，欢迎通过以下方式联系：

- 提交 [Issue](https://github.com/duke-yeah/memoranote/issues)
- Pull Request

---

<div align="center">

**享受极光科技记事体验！**

Made with 💜 by [duke-yeah](https://github.com/duke-yeah)

</div>
