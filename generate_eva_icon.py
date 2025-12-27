#!/usr/bin/env python3
"""
Memora EVA 主题图标生成器
设计方案：初号机·觉醒 (Unit-01 Awakening)
基于 NERV 风格和初号机配色设计
"""

import os

# EVA 主题色彩配置
COLORS = {
    'purple': '#6E2C90',      # 初号机紫（主色）
    'green': '#39FF14',       # 初号机绿（高光）
    'orange': '#FF6B00',      # EVA 橙（强调）
    'black': '#0D0D0D',       # 深空黑（背景）
    'dark_purple': '#501870', # 暗紫（阴影）
    'grid': '#1A1A1A',        # 网格线
}

# SVG 图标内容
# 设计元素说明：
# 1. 背景：深空黑 + 六边形蜂巢网格（MAGI 系统风格）
# 2. 主体装甲：初号机紫色 V 型装甲，模拟机体胸甲轮廓
# 3. 荧光带：初号机绿色发光带，象征眼部/能量带
# 4. 中央标志：橙色锐利 M 字标志，融合 NERV 字体风格
# 5. 细节装饰：科技感小元素（矩形、圆形指示灯）
svg_template = f"""<?xml version="1.0" encoding="UTF-8"?>
<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
    <defs>
        <!-- 六边形蜂巢背景纹理 -->
        <pattern id="hexPattern" x="0" y="0" width="80" height="138.56" patternUnits="userSpaceOnUse">
            <path d="M40 0 L80 23.09 L80 69.28 L40 92.37 L0 69.28 L0 23.09 Z"
                  fill="none" stroke="{COLORS['grid']}" stroke-width="1.5" opacity="0.3"/>
        </pattern>

        <!-- 荧光绿发光效果 -->
        <filter id="greenGlow">
            <feGaussianBlur stdDeviation="8" result="coloredBlur"/>
            <feMerge>
                <feMergeNode in="coloredBlur"/>
                <feMergeNode in="SourceGraphic"/>
            </feMerge>
        </filter>

        <!-- 线性渐变 - 装甲深度感 -->
        <linearGradient id="armorGradient" x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" style="stop-color:{COLORS['purple']};stop-opacity:1" />
            <stop offset="100%" style="stop-color:{COLORS['dark_purple']};stop-opacity:1" />
        </linearGradient>
    </defs>

    <!-- 第一层：深空黑背景 -->
    <rect width="1024" height="1024" fill="{COLORS['black']}" rx="180"/>

    <!-- 第二层：六边形蜂巢背景 -->
    <rect width="1024" height="1024" fill="url(#hexPattern)" rx="180"/>

    <!-- 第三层：主体装甲轮廓 (初号机紫) -->
    <!-- V 型装甲，模拟初号机胸部装甲切割线条 -->
    <path d="M 150 220
             L 874 220
             Q 900 220 900 246
             L 850 820
             Q 850 850 820 870
             L 550 980
             Q 512 1000 474 980
             L 204 870
             Q 174 850 174 820
             L 124 246
             Q 124 220 150 220 Z"
          fill="url(#armorGradient)"
          stroke="{COLORS['dark_purple']}"
          stroke-width="8"/>

    <!-- 内部细节：中央分割线 -->
    <line x1="512" y1="280" x2="512" y2="950"
          stroke="{COLORS['dark_purple']}"
          stroke-width="4"
          opacity="0.6"/>

    <!-- 第四层：荧光绿发光带（顶部，模拟初号机眼部） -->
    <g filter="url(#greenGlow)">
        <!-- 主发光带 -->
        <path d="M 200 280
                 L 824 280
                 L 780 360
                 L 244 360 Z"
              fill="{COLORS['green']}"
              opacity="0.9"/>

        <!-- 内层高亮 -->
        <rect x="220" y="300" width="584" height="40"
              fill="{COLORS['green']}"
              opacity="0.6"/>
    </g>

    <!-- 第五层：中央 M 标志（EVA 橙，锐利字体） -->
    <!-- 设计为类似 NERV 标志的锐角几何字母 -->
    <g>
        <path d="M 360 480
                 L 420 480
                 L 512 680
                 L 604 480
                 L 664 480
                 L 634 780
                 L 574 780
                 L 512 640
                 L 450 780
                 L 390 780 Z"
              fill="{COLORS['orange']}"
              stroke="{COLORS['black']}"
              stroke-width="3"/>
    </g>

    <!-- 第六层：科技细节装饰 -->
    <!-- 顶部状态指示条 -->
    <rect x="462" y="140" width="100" height="16"
          fill="{COLORS['orange']}"
          rx="8"
          opacity="0.8"/>

    <!-- 底部圆形核心指示灯 -->
    <circle cx="512" cy="880" r="24"
            fill="{COLORS['green']}"
            opacity="0.8"/>
    <circle cx="512" cy="880" r="16"
            fill="{COLORS['black']}"
            opacity="0.4"/>

    <!-- 边角装饰：左上 -->
    <rect x="140" y="240" width="6" height="60"
          fill="{COLORS['green']}"
          opacity="0.6"/>
    <rect x="140" y="240" width="60" height="6"
          fill="{COLORS['green']}"
          opacity="0.6"/>

    <!-- 边角装饰：右上 -->
    <rect x="878" y="240" width="6" height="60"
          fill="{COLORS['green']}"
          opacity="0.6"/>
    <rect x="824" y="240" width="60" height="6"
          fill="{COLORS['green']}"
          opacity="0.6"/>
</svg>
"""

def main():
    """生成 SVG 图标文件"""
    output_file = "memora_eva_icon.svg"

    # 写入 SVG 文件
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(svg_template)

    print("✅ EVA 主题图标已生成！")
    print(f"📁 文件位置: {os.path.abspath(output_file)}")
    print("\n📋 后续步骤：")
    print("1. 在浏览器中打开 memora_eva_icon.svg 预览效果")
    print("2. 使用在线工具或设计软件导出为 1024x1024 PNG")
    print("   推荐工具: https://cloudconvert.com/svg-to-png")
    print("3. 将导出的 PNG 重命名为 icon_1024.png")
    print("4. 运行脚本生成所有尺寸: ./fix_appicon.sh")

if __name__ == "__main__":
    main()
