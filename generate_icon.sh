#!/bin/bash

# Memora 应用图标生成脚本
# 使用 sips 和 SF Symbols 创建临时图标

ICON_DIR="/Users/huayang.sun/Desktop/AI/appmacos/Memora/Memora/Assets.xcassets/AppIcon.appiconset"

echo "📱 开始生成 Memora 应用图标..."

# 创建一个临时目录
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# 创建一个简单的橙色图标（使用 ImageMagick 或手动方式）
# 注意：macOS 自带的工具有限，这里提供手动方式

cat << 'EOF'

由于 macOS 自带工具限制，请使用以下任一方法：

方法 A - 使用预览应用快速创建：
1. 打开"预览"应用
2. 文件 → 新建 → 从剪贴板创建
3. 或者创建一个空白文档，设置为 1024x1024
4. 使用标记工具：
   - 填充橙色背景
   - 添加白色矩形和线条模拟笔记本
5. 导出为 PNG

方法 B - 使用在线工具（推荐）：
1. 访问 https://www.canva.com
2. 创建 1024x1024 画布
3. 使用橙色渐变背景 + 笔记本图标
4. 下载为 PNG

方法 C - 使用 icon.kitchen：
1. 访问 https://icon.kitchen
2. 选择图标类型：Clipart
3. 搜索 "note" 或 "notebook"
4. 设置背景色为橙色 (#FF9500)
5. 生成并下载所有尺寸

完成后，请执行：
./import_icon.sh <你的1024x1024图标文件路径>

EOF

# 创建导入脚本
cat > import_icon.sh << 'IMPORT_SCRIPT'
#!/bin/bash

if [ -z "$1" ]; then
    echo "用法: ./import_icon.sh <icon.png>"
    exit 1
fi

SOURCE_ICON="$1"
ICON_DIR="/Users/huayang.sun/Desktop/AI/appmacos/Memora/Memora/Assets.xcassets/AppIcon.appiconset"

if [ ! -f "$SOURCE_ICON" ]; then
    echo "❌ 文件不存在: $SOURCE_ICON"
    exit 1
fi

echo "🎨 开始生成各种尺寸的图标..."

# macOS 图标尺寸
declare -a SIZES=("16" "32" "128" "256" "512")
declare -a SCALES=("1x" "2x")

for size in "${SIZES[@]}"; do
    for scale in "${SCALES[@]}"; do
        if [ "$scale" == "1x" ]; then
            actual_size=$size
        else
            actual_size=$((size * 2))
        fi

        output_file="$ICON_DIR/icon_${size}x${size}@${scale}.png"

        echo "生成 ${size}x${size}@${scale} (${actual_size}x${actual_size})"
        sips -z $actual_size $actual_size "$SOURCE_ICON" --out "$output_file" > /dev/null 2>&1
    done
done

echo "✅ 图标生成完成！"
echo "📝 请在 Xcode 中打开项目，选择 Assets.xcassets → AppIcon 查看"
echo "🔨 然后重新编译项目即可看到新图标"

IMPORT_SCRIPT

chmod +x import_icon.sh
mv import_icon.sh "$ICON_DIR/../"

echo "✅ 导入脚本已创建在: $ICON_DIR/../import_icon.sh"
