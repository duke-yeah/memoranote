#!/bin/bash

# Memora EVA 图标转换和安装脚本
# 功能：将 SVG 转换为 PNG，并生成所有尺寸的应用图标

set -e

echo "🎨 Memora EVA 图标转换和安装"
echo "=============================="

# 检查 SVG 文件是否存在
if [ ! -f "memora_eva_icon.svg" ]; then
    echo "❌ 错误: memora_eva_icon.svg 不存在"
    echo "请先运行: python3 generate_eva_icon.py"
    exit 1
fi

# 方法 1: 尝试使用 rsvg-convert (最佳质量)
if command -v rsvg-convert &> /dev/null; then
    echo "✅ 使用 rsvg-convert 转换..."
    rsvg-convert -w 1024 -h 1024 memora_eva_icon.svg -o icon_1024.png
    echo "✅ 已生成 icon_1024.png"

# 方法 2: 尝试使用 qlmanage + sips (macOS 原生)
elif command -v qlmanage &> /dev/null; then
    echo "⚙️  使用 macOS 原生工具转换..."

    # 使用 qlmanage 生成预览图
    qlmanage -t -s 1024 -o . memora_eva_icon.svg 2>/dev/null

    # 重命名生成的文件
    if [ -f "memora_eva_icon.svg.png" ]; then
        mv memora_eva_icon.svg.png icon_1024.png
        echo "✅ 已生成 icon_1024.png"
    else
        echo "❌ qlmanage 转换失败"
        echo ""
        echo "📋 请手动转换 SVG："
        echo "1. 在浏览器中打开 memora_eva_icon.svg"
        echo "2. 使用在线工具转换: https://cloudconvert.com/svg-to-png"
        echo "3. 设置尺寸为 1024x1024"
        echo "4. 下载并重命名为 icon_1024.png"
        echo "5. 将文件放在当前目录，然后重新运行此脚本"
        exit 1
    fi

# 方法 3: 提示用户手动转换
else
    echo "⚠️  未找到自动转换工具"
    echo ""
    echo "📋 请手动转换 SVG："
    echo "1. 在浏览器中打开 memora_eva_icon.svg"
    echo "2. 右键 → 检查 → Console"
    echo "3. 运行以下代码复制为 PNG："
    echo ""
    echo "   或使用在线工具: https://cloudconvert.com/svg-to-png"
    echo ""
    echo "4. 设置尺寸为 1024x1024，下载后重命名为 icon_1024.png"
    echo "5. 将文件放在当前目录，然后重新运行此脚本"
    exit 1
fi

# 检查 icon_1024.png 是否存在
if [ ! -f "icon_1024.png" ]; then
    echo "❌ icon_1024.png 未找到，无法继续"
    exit 1
fi

echo ""
echo "📦 开始生成所有尺寸的图标..."
echo ""

# 定义所有需要的尺寸 (AppIcon.appiconset)
SIZES=(16 32 64 128 256 512 1024)

# Assets 目录路径
ASSETS_DIR="Memora/Assets.xcassets/AppIcon.appiconset"

# 检查目录是否存在
if [ ! -d "$ASSETS_DIR" ]; then
    echo "❌ 错误: 找不到 $ASSETS_DIR"
    exit 1
fi

# 生成各种尺寸
for size in "${SIZES[@]}"; do
    # 1x 版本
    echo "  生成 icon_${size}x${size}.png"
    sips -z $size $size icon_1024.png --out "$ASSETS_DIR/icon_${size}x${size}.png" > /dev/null 2>&1

    # 2x 版本 (尺寸翻倍)
    if [ $size -le 512 ]; then
        double_size=$((size * 2))
        echo "  生成 icon_${size}x${size}@2x.png"
        sips -z $double_size $double_size icon_1024.png --out "$ASSETS_DIR/icon_${size}x${size}@2x.png" > /dev/null 2>&1
    fi
done

# 复制原始 1024x1024
cp icon_1024.png "$ASSETS_DIR/icon_1024x1024.png"

echo ""
echo "✅ 所有图标已生成！"
echo ""
echo "📋 生成的文件："
echo "  - icon_16x16.png"
echo "  - icon_16x16@2x.png (32x32)"
echo "  - icon_32x32.png"
echo "  - icon_32x32@2x.png (64x64)"
echo "  - icon_64x64.png"
echo "  - icon_64x64@2x.png (128x128)"
echo "  - icon_128x128.png"
echo "  - icon_128x128@2x.png (256x256)"
echo "  - icon_256x256.png"
echo "  - icon_256x256@2x.png (512x512)"
echo "  - icon_512x512.png"
echo "  - icon_512x512@2x.png (1024x1024)"
echo "  - icon_1024x1024.png"
echo ""
echo "🎉 EVA 主题图标安装完成！"
echo ""
echo "🚀 下一步："
echo "1. 在 Xcode 中打开项目"
echo "2. Product → Clean Build Folder (⇧⌘K)"
echo "3. 运行项目查看新图标 (⌘R)"
