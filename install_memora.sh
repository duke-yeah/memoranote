#!/bin/bash

echo "🔨 正在编译 Memora 应用..."
echo ""

# 编译应用
xcodebuild -project Memora.xcodeproj \
           -scheme Memora \
           -configuration Release \
           -derivedDataPath ./build \
           clean build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 编译成功！"
    echo ""

    # 查找生成的应用
    APP_PATH="./build/Build/Products/Release/Memora.app"

    if [ -d "$APP_PATH" ]; then
        echo "📦 正在安装到 Applications 文件夹..."

        # 如果已存在，先删除
        if [ -d "/Applications/Memora.app" ]; then
            rm -rf "/Applications/Memora.app"
            echo "🗑️  已删除旧版本"
        fi

        # 复制到 Applications
        cp -R "$APP_PATH" /Applications/

        echo ""
        echo "🎉 安装完成！"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📱 Memora 已安装到:"
        echo "   /Applications/Memora.app"
        echo ""
        echo "💡 首次打开步骤:"
        echo "   1. 打开 Applications 文件夹"
        echo "   2. 右键点击 Memora"
        echo "   3. 选择「打开」"
        echo "   4. 在弹出框中点击「打开」"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""

        # 询问是否立即打开
        read -p "是否现在打开 Memora？(y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            open /Applications/Memora.app
        fi
    else
        echo "❌ 错误：找不到编译的应用文件"
        echo "   预期位置: $APP_PATH"
    fi
else
    echo ""
    echo "❌ 编译失败"
    echo "   请检查 Xcode 是否正确安装"
fi
