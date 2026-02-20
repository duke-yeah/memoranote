//
//  DesignSystem.swift
//  Memora
//
//  Created by Claude Code
//  Copyright © 2025 Memora. All rights reserved.
//

import SwiftUI

#if os(macOS)
import AppKit
#endif

/// Memora 设计系统 - 极光科技主题
/// 核心视觉：深色背景 + 橙紫主色 + 等宽字体数据面板风格
enum DesignSystem {
    // MARK: - Colors

    /// 颜色系统 - 橙紫主题
    enum Colors {
        // MARK: 背景色系统

        /// 主背景色
        static let background = Color(hex: 0x0A0A0F)

        /// 次级背景色（卡片/面板背景）
        static let secondaryBackground = Color(hex: 0x14141B)

        /// 三级背景色（输入框/对话框背景）
        static let tertiaryBackground = Color(hex: 0x1E1E2A)

        // MARK: 主题色 - 橙紫配色

        /// 主色（紫）
        static let primary = Color(hex: 0x8B5CF6)

        /// 次色（深紫）
        static let secondary = Color(hex: 0x6D28D9)

        /// 强调色（橙）
        static let accent = Color(hex: 0xF97316)

        /// 警报色
        static let alert = Color(hex: 0xEF4444)

        /// 信息提示色
        static let info = Color(hex: 0x3B82F6)

        // MARK: 文本色系统

        /// 主要文本颜色（暖橙）
        static let textPrimary = Color(hex: 0xFED7AA)

        /// 次要文本颜色（浅橙）
        static let textSecondary = Color(hex: 0xFDBA74)

        /// 三级文本颜色（中橙）
        static let textTertiary = Color(hex: 0xFB923C)

        // MARK: 功能色（兼容旧版）

        /// 成功状态色
        static let success = primary

        /// 警告状态色
        static let warning = accent

        /// 错误状态色
        static let error = alert

        // MARK: 优先级语义色

        /// 高优先级颜色（橙）
        static let highPriority = accent

        /// 中优先级颜色（紫）
        static let mediumPriority = primary

        /// 低优先级颜色（深紫）
        static let lowPriority = secondary
    }

    // MARK: - Spacing

    /// 间距系统（保持原有规范）
    enum Spacing {
        /// 超小间距 (4pt)
        static let xSmall: CGFloat = 4

        /// 小间距 (8pt)
        static let small: CGFloat = 8

        /// 中等间距 (12pt)
        static let medium: CGFloat = 12

        /// 大间距 (16pt)
        static let large: CGFloat = 16

        /// 超大间距 (24pt)
        static let xLarge: CGFloat = 24

        /// 特大间距 (32pt)
        static let xxLarge: CGFloat = 32
    }

    // MARK: - Corner Radius

    /// 圆角系统 - EVA 风格（更锐利的切角）
    enum CornerRadius {
        /// 小圆角 (2pt) - 锐利风格
        static let small: CGFloat = 2

        /// 中等圆角 (4pt)
        static let medium: CGFloat = 4

        /// 大圆角 (8pt)
        static let large: CGFloat = 8

        /// 超大圆角 (12pt)
        static let xLarge: CGFloat = 12
    }

    // MARK: - Typography

    /// 字体系统 - EVA 风格（等宽字体增强科技感）
    enum Typography {
        /// 超大标题 - 等宽粗体
        static let largeTitle = Font.system(.largeTitle, design: .monospaced).weight(.black)

        /// 大标题 - 等宽粗体
        static let title = Font.system(.title, design: .monospaced).weight(.bold)

        /// 标题2 - 等宽粗体
        static let title2 = Font.system(.title2, design: .monospaced).weight(.bold)

        /// 标题3 - 等宽半粗体
        static let title3 = Font.system(.title3, design: .monospaced).weight(.semibold)

        /// 正文 - 等宽常规
        static let body = Font.system(.body, design: .monospaced)

        /// 次要正文 - 等宽常规
        static let callout = Font.system(.callout, design: .monospaced)

        /// 小字 - 等宽常规
        static let footnote = Font.system(.footnote, design: .monospaced)

        /// 说明文字 - 等宽常规
        static let caption = Font.system(.caption, design: .monospaced)

        /// 超小文字 - 等宽常规
        static let caption2 = Font.system(.caption2, design: .monospaced)

        /// 数字显示专用 - 等宽中粗（用于时间、进度等数据）
        static let digital = Font.system(.body, design: .monospaced).weight(.medium)
    }

    // MARK: - Icons

    /// SF Symbols 图标系统 - EVA 风格选择
    enum Icons {
        // MARK: 基础图标

        /// 添加
        static let add = "plus"

        /// 搜索
        static let search = "magnifyingglass"

        /// 筛选
        static let filter = "line.3.horizontal.decrease.circle"

        // MARK: 状态图标 - 使用六边形增强科技感

        /// 未完成 - 六边形空心
        static let unchecked = "hexagon"

        /// 已完成 - 六边形实心
        static let checked = "hexagon.fill"

        // MARK: 功能图标

        /// 优先级标记 - 警告三角
        static let priorityFlag = "exclamationmark.triangle.fill"

        /// 日历时钟
        static let calendar = "calendar.badge.clock"

        /// 时钟
        static let clock = "clock"

        /// 删除 - X 圆圈
        static let delete = "xmark.circle"

        /// 删除（填充）
        static let deleteFill = "xmark.circle.fill"

        /// 编辑
        static let edit = "pencil"

        /// 编辑（填充）
        static let editFill = "pencil.circle.fill"

        /// 列表
        static let list = "list.bullet.rectangle"

        /// 进度图表
        static let progress = "chart.bar.fill"
    }

    // MARK: - Animation

    /// 动画系统（更快速、更有力）
    enum Animation {
        /// 快速动画 - 用于即时反馈
        static let fast = SwiftUI.Animation.easeInOut(duration: 0.15)

        /// 标准动画 - 用于常规交互
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.25)

        /// 慢速动画 - 用于复杂状态转换
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.4)

        /// 弹簧动画 - EVA 风格（高阻尼）
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)

        /// 机械动画 - 精准线性（用于数据更新）
        static let mechanical = SwiftUI.Animation.linear(duration: 0.2)
    }
}

// MARK: - Convenience Extensions

extension Color {
    /// 从十六进制创建颜色
    /// - Parameters:
    ///   - hex: 十六进制颜色值 (例如: 0xFF6B00)
    ///   - alpha: 透明度 (0.0 - 1.0)
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }

    /// 从 DesignSystem 获取优先级颜色
    /// - Parameter priority: 优先级枚举值
    /// - Returns: 对应的颜色
    static func priority(_ priority: NotePriority) -> Color {
        switch priority {
        case .high:
            return DesignSystem.Colors.highPriority
        case .medium:
            return DesignSystem.Colors.mediumPriority
        case .low:
            return DesignSystem.Colors.lowPriority
        }
    }
}
