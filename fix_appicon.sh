#!/bin/bash

echo "🔧 开始修复 Memora 应用图标..."

ICNS_FILE="/Users/huayang.sun/Desktop/AI/appmacos/Memora/Memora/Assets.xcassets/macos/AppIcon.dataset/AppIcon.icns"
APPICON_DIR="/Users/huayang.sun/Desktop/AI/appmacos/Memora/Memora/Assets.xcassets/AppIcon.appiconset"

# 检查 icns 文件是否存在
if [ ! -f "$ICNS_FILE" ]; then
    echo "❌ 找不到 icns 文件"
    exit 1
fi

echo "📦 找到图标文件: AppIcon.icns"
echo "🔨 开始从 icns 文件提取各种尺寸..."

# 创建临时目录
TEMP_DIR=$(mktemp -d)

# 使用 sips 从 icns 提取最大尺寸作为基础
echo "  → 提取基础图像..."
sips -s format png "$ICNS_FILE" --out "$TEMP_DIR/base.png" &>/dev/null

# 生成所需的所有尺寸
echo "  → 生成各种尺寸..."

sips -z 16 16 "$TEMP_DIR/base.png" --out "$APPICON_DIR/icon_16x16.png" &>/dev/null
echo "    ✓ icon_16x16.png"

sips -z 32 32 "$TEMP_DIR/base.png" --out "$APPICON_DIR/icon_16x16@2x.png" &>/dev/null
echo "    ✓ icon_16x16@2x.png"

sips -z 32 32 "$TEMP_DIR/base.png" --out "$APPICON_DIR/icon_32x32.png" &>/dev/null
echo "    ✓ icon_32x32.png"

sips -z 64 64 "$TEMP_DIR/base.png" --out "$APPICON_DIR/icon_32x32@2x.png" &>/dev/null
echo "    ✓ icon_32x32@2x.png"

sips -z 128 128 "$TEMP_DIR/base.png" --out "$APPICON_DIR/icon_128x128.png" &>/dev/null
echo "    ✓ icon_128x128.png"

sips -z 256 256 "$TEMP_DIR/base.png" --out "$APPICON_DIR/icon_128x128@2x.png" &>/dev/null
echo "    ✓ icon_128x128@2x.png"

sips -z 256 256 "$TEMP_DIR/base.png" --out "$APPICON_DIR/icon_256x256.png" &>/dev/null
echo "    ✓ icon_256x256.png"

sips -z 512 512 "$TEMP_DIR/base.png" --out "$APPICON_DIR/icon_256x256@2x.png" &>/dev/null
echo "    ✓ icon_256x256@2x.png"

sips -z 512 512 "$TEMP_DIR/base.png" --out "$APPICON_DIR/icon_512x512.png" &>/dev/null
echo "    ✓ icon_512x512.png"

sips -z 1024 1024 "$TEMP_DIR/base.png" --out "$APPICON_DIR/icon_512x512@2x.png" &>/dev/null
echo "    ✓ icon_512x512@2x.png"

# 更新 Contents.json
cat > "$APPICON_DIR/Contents.json" << 'EOF'
{
  "images" : [
    {
      "filename" : "icon_16x16.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_16x16@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_32x32.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_32x32@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_128x128.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_128x128@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_256x256.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_256x256@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_512x512.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "512x512"
    },
    {
      "filename" : "icon_512x512@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "512x512"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# 清理临时文件
rm -rf "$TEMP_DIR"

echo ""
echo "✅ 图标修复完成！"
echo ""
echo "📋 已生成的文件："
ls -1 "$APPICON_DIR"/*.png 2>/dev/null | while read file; do
    echo "  ✓ $(basename "$file")"
done
echo ""
echo "🔨 下一步操作："
echo "  1. 在 Xcode 中按 ⌘+Shift+K (Clean Build Folder)"
echo "  2. 按 ⌘+R 重新运行项目"
echo "  3. 图标应该会正确显示 ✨"
echo ""
