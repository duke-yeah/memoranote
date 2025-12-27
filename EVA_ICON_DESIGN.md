# Memora EVA 主题图标设计说明

## 🎨 设计概念

### 方案：初号机·觉醒 (Unit-01 Awakening)

这是一个基于《新世纪福音战士》(Evangelion) NERV 风格设计的应用图标，融合了初号机的标志性视觉元素。

## 🎯 设计元素

### 核心视觉
1. **V 型装甲轮廓**
   - 模拟初号机的胸部装甲切割线条
   - 使用初号机紫 (#6E2C90) 作为主色调
   - 渐变效果增强立体感和深度

2. **荧光绿发光带**
   - 模拟初号机标志性的眼部发光效果
   - 使用初号机绿 (#39FF14) 高亮色
   - 添加发光滤镜增强科技感

3. **中央 M 标志**
   - 锐角几何设计，模仿 NERV 标志字体风格
   - 使用 EVA 橙 (#FF6B00) 强调色
   - 代表 "Memora" 的首字母

4. **科技细节装饰**
   - 顶部状态指示条
   - 底部核心指示灯
   - 边角 L 型装饰线

5. **背景纹理**
   - 深空黑 (#0D0D0D) 主背景
   - 六边形蜂巢网格（模拟 MAGI 系统）
   - 180px 圆角增强现代感

## 🎨 色彩配置

| 颜色名称 | 十六进制 | 用途 |
|---------|---------|------|
| 初号机紫 | `#6E2C90` | 主色调（装甲） |
| 初号机绿 | `#39FF14` | 高光色（发光带） |
| EVA 橙 | `#FF6B00` | 强调色（M 标志） |
| 深空黑 | `#0D0D0D` | 背景色 |
| 暗紫 | `#501870` | 阴影和描边 |

## 📐 技术规格

### 生成尺寸
所有标准 macOS/iOS 应用图标尺寸：

| 尺寸 | 用途 | 文件名 |
|-----|------|--------|
| 16x16 | macOS Dock（缩小） | icon_16x16.png |
| 32x32 | macOS Dock | icon_32x32.png |
| 64x64 | macOS 通知 | icon_64x64.png |
| 128x128 | macOS Finder | icon_128x128.png |
| 256x256 | macOS Finder（标准） | icon_256x256.png |
| 512x512 | macOS App Store | icon_512x512.png |
| 1024x1024 | 原始大图 | icon_1024x1024.png |

每个尺寸还包含 @2x 高分辨率版本（Retina 显示屏）。

### 文件格式
- **源文件**: SVG 矢量格式 (`memora_eva_icon.svg`)
- **导出格式**: PNG 24-bit RGB + Alpha
- **色彩空间**: sRGB
- **圆角半径**: 180px（基于 1024x1024）

## 🛠️ 使用方法

### 重新生成图标

如果需要修改设计，按以下步骤操作：

```bash
# 1. 编辑 Python 脚本
nano generate_eva_icon.py

# 2. 重新生成 SVG
python3 generate_eva_icon.py

# 3. 转换并安装所有尺寸
./convert_and_install_icon.sh

# 4. 在 Xcode 中清理并重新构建
# Product → Clean Build Folder (⇧⌘K)
# 然后运行项目 (⌘R)
```

### 自定义颜色

编辑 `generate_eva_icon.py` 中的 `COLORS` 字典：

```python
COLORS = {
    'purple': '#6E2C90',      # 主色调
    'green': '#39FF14',       # 高光色
    'orange': '#FF6B00',      # 强调色
    'black': '#0D0D0D',       # 背景色
}
```

## 🎯 设计理念

### 为什么选择初号机主题？

1. **高辨识度**: 紫绿配色是 EVA 最经典的视觉符号
2. **高对比度**: 荧光绿在深色背景下非常醒目
3. **科技感强**: 几何装甲线条契合"科技感"需求
4. **主题统一**: 与应用内 EVA 主题完美呼应

### 设计约束

- ✅ 简洁：核心元素不超过 5 个
- ✅ 可缩放：在 16x16 到 1024x1024 所有尺寸下清晰
- ✅ 高对比：深色模式和浅色模式下都清晰可见
- ✅ 品牌化：融入 Memora 品牌元素（M 字标志）

## 📋 文件清单

```
Memora/
├── generate_eva_icon.py           # 图标生成脚本
├── convert_and_install_icon.sh    # 转换和安装脚本
├── memora_eva_icon.svg           # SVG 源文件
├── icon_1024.png                 # 临时 1024px PNG
└── Memora/Assets.xcassets/AppIcon.appiconset/
    ├── icon_16x16.png
    ├── icon_16x16@2x.png
    ├── icon_32x32.png
    ├── icon_32x32@2x.png
    ├── icon_64x64.png
    ├── icon_64x64@2x.png
    ├── icon_128x128.png
    ├── icon_128x128@2x.png
    ├── icon_256x256.png
    ├── icon_256x256@2x.png
    ├── icon_512x512.png
    ├── icon_512x512@2x.png
    └── icon_1024x1024.png
```

## 🎊 完成状态

- ✅ SVG 源文件已生成
- ✅ 所有 13 个尺寸的 PNG 图标已生成
- ✅ 图标已安装到 Assets.xcassets
- ✅ 准备好在 Xcode 中使用

## 🚀 下一步

1. 在 Xcode 中打开 `Memora.xcodeproj`
2. Product → Clean Build Folder (⇧⌘K)
3. 运行项目 (⌘R) 查看新图标效果

---

**设计时间**: 2025-12-28
**设计者**: Claude Code + Gemini
**主题**: EVA (新世纪福音战士) NERV 风格
