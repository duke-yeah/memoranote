# Memora 应用安装和使用指南

## 🎯 个人使用 macOS 应用的方式

**好消息**: 完全不需要上架 App Store！以下是几种在你自己 Mac 上使用 Memora 的方法。

---

## 方式 1: 直接从 Xcode 运行（最简单）⭐️

### 优点
- ✅ 最简单，一键运行
- ✅ 自动更新代码修改
- ✅ 方便调试

### 使用步骤

1. **在 Xcode 中打开项目**
   ```bash
   cd /Users/huayang.sun/Desktop/AI/appmacos/Memora
   open Memora.xcodeproj
   ```

2. **运行应用**
   - 点击 Xcode 左上角的 ▶️ 按钮
   - 或按快捷键 `⌘R`

3. **应用会启动**
   - Memora 会出现在你的 Dock 栏
   - 可以正常使用所有功能

### 注意事项
- 关闭 Xcode 时应用也会关闭
- 每次使用需要从 Xcode 运行

---

## 方式 2: Archive 并安装到 Applications（推荐）⭐️⭐️⭐️

### 优点
- ✅ 创建独立的应用
- ✅ 可以放到 Applications 文件夹
- ✅ 像普通 Mac 应用一样使用
- ✅ 不依赖 Xcode

### 详细步骤

#### 第一步：Archive 应用

1. **在 Xcode 中打开项目**

2. **选择目标设备**
   - 点击 Xcode 顶部工具栏的设备选择器
   - 选择 **"Any Mac (Apple Silicon)"** 或 **"Any Mac (Intel)"**
     - 如果你的 Mac 是 M1/M2/M3 芯片，选择 Apple Silicon
     - 如果是 Intel 芯片，选择 Intel

3. **创建 Archive**
   - 菜单: `Product` → `Archive`
   - 等待编译完成（可能需要 1-2 分钟）

4. **打开 Organizer**
   - Archive 完成后会自动打开 Organizer 窗口
   - 如果没有打开，菜单: `Window` → `Organizer`

#### 第二步：导出应用

1. **在 Organizer 中选择刚创建的 Archive**
   - 左侧选择 "Memora"
   - 右侧显示 Archive 列表

2. **点击 "Distribute App" 按钮**

3. **选择分发方式**
   - 选择 **"Copy App"** （复制应用）
   - 点击 **"Next"**

4. **选择导出位置**
   - 选择保存位置（推荐桌面）
   - 点击 **"Export"**

5. **获得 Memora.app**
   - 在导出位置会看到 `Memora.app` 文件

#### 第三步：安装应用

1. **将 Memora.app 拖到 Applications 文件夹**
   ```bash
   # 或使用命令行
   mv ~/Desktop/Memora.app /Applications/
   ```

2. **首次打开可能遇到安全提示**
   - macOS 会提示 "无法打开，因为无法验证开发者"
   - 这是正常的，因为我们没有 Apple Developer 账号签名

3. **允许打开应用**

   **方法 A: 右键打开**
   - 在 Finder 中右键点击 `Memora.app`
   - 选择 **"打开"**
   - 在弹出的对话框中点击 **"打开"**

   **方法 B: 系统设置**
   - 打开 **系统设置** → **隐私与安全性**
   - 找到 "Memora 已被阻止..." 的提示
   - 点击 **"仍要打开"**

4. **完成！**
   - 以后可以像普通应用一样从 Launchpad 或 Applications 启动

---

## 方式 3: 开发者签名（可选）

如果你有 Apple Developer 账号（$99/年），可以签名应用以避免安全警告。

### 步骤

1. **在 Xcode 中配置签名**
   - 选中项目 → 选择 Target "Memora"
   - 点击 **"Signing & Capabilities"**
   - 勾选 **"Automatically manage signing"**
   - 选择你的 Team（需要登录 Apple ID）

2. **然后按方式 2 的步骤 Archive 和导出**

3. **这样导出的应用可以直接打开，无需安全授权**

---

## 📱 数据存储位置

Memora 的数据存储在：
```
~/Library/Containers/com.memora.Memora/Data/Library/Application Support/
```

### 备份数据
```bash
# 复制数据到桌面备份
cp -r ~/Library/Containers/com.memora.Memora ~/Desktop/Memora_Backup
```

### 恢复数据
```bash
# 从备份恢复数据
cp -r ~/Desktop/Memora_Backup ~/Library/Containers/com.memora.Memora
```

---

## 🔄 更新应用

### 如果修改了代码

1. **在 Xcode 中修改代码**

2. **重新 Archive**
   - `Product` → `Archive`

3. **导出并替换旧版本**
   - 导出新的 `Memora.app`
   - 删除 Applications 中的旧版本
   - 拖入新版本

### 数据会保留吗？
- ✅ 会保留！只要应用的 Bundle Identifier 不变
- SwiftData 数据存储在独立的位置，不受应用更新影响

---

## 🚀 高级选项

### 在多台 Mac 上使用

如果你想在多台 Mac 上使用 Memora：

1. **打包应用为 .dmg 或 .zip**
   ```bash
   # 创建 zip 包
   cd /Applications
   zip -r ~/Desktop/Memora.zip Memora.app
   ```

2. **复制到其他 Mac**
   - 通过 AirDrop、U 盘或云盘传输
   - 在其他 Mac 上解压并拖到 Applications

3. **数据不会自动同步**
   - 每台 Mac 有独立的数据
   - 如需同步，需要手动实现 iCloud 同步（需要修改代码）

### 创建快捷启动方式

1. **添加到 Dock**
   - 打开应用后，在 Dock 中右键点击图标
   - 选择 **"选项"** → **"在 Dock 中保留"**

2. **创建快捷键**
   - 系统设置 → 键盘 → 键盘快捷键 → App 快捷键
   - 添加 Memora 的启动快捷键

---

## ❓ 常见问题

### Q: 需要一直连着 Xcode 吗？
**A:** 不需要。使用方式 2 导出后，应用是完全独立的。

### Q: 可以分享给朋友使用吗？
**A:**
- 可以，但他们也需要按照"允许打开应用"的步骤操作
- 如果想方便分享，需要 Apple Developer 账号签名

### Q: 数据会丢失吗？
**A:**
- 不会，数据存储在系统的 Application Support 目录
- 即使删除应用，数据也会保留
- 建议定期备份重要数据

### Q: 能在 iPhone/iPad 上用吗？
**A:**
- 当前版本只支持 macOS
- 如需 iOS 版本，需要修改部分代码适配移动设备

### Q: 上架 App Store 需要什么？
**A:**
- Apple Developer 账号（$99/年）
- 应用审核（1-2 周）
- 遵守 App Store 审核指南
- **个人使用完全不需要**

---

## 📋 推荐使用方式

### 对于日常使用
**推荐：方式 2（Archive 并安装到 Applications）**
- 像普通应用一样使用
- 启动快速
- 不占用 Xcode

### 对于开发测试
**推荐：方式 1（从 Xcode 运行）**
- 方便修改和调试
- 实时查看日志

---

## ✅ 快速开始

### 最快捷的方式（5 分钟内完成）

```bash
# 1. 打开项目
cd /Users/huayang.sun/Desktop/AI/appmacos/Memora
open Memora.xcodeproj

# 2. 在 Xcode 中按 ⌘R 运行

# 3. 开始使用！
```

### 安装为独立应用（10 分钟内完成）

1. Xcode: `Product` → `Archive`
2. Organizer: `Distribute App` → `Copy App`
3. 拖到 `/Applications/`
4. 右键 → 打开
5. 完成！

---

**现在就可以开始使用你的 Memora 应用了！** 🎉

如果遇到任何问题，请参考上面的详细步骤或常见问题部分。
