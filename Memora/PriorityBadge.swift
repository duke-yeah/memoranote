//
//  PriorityBadge.swift
//  Memora
//
//  Created by Claude Code
//  Copyright © 2025 Memora. All rights reserved.
//

import SwiftUI

/// 优先级标签组件
/// 以胶囊形状展示优先级，使用不同颜色和图标区分
struct PriorityBadge: View {
    // MARK: - Properties

    let priority: NotePriority
    let showIcon: Bool

    // MARK: - Initialization

    /// 初始化优先级标签
    /// - Parameters:
    ///   - priority: 优先级
    ///   - showIcon: 是否显示图标，默认为 true
    init(priority: NotePriority, showIcon: Bool = true) {
        self.priority = priority
        self.showIcon = showIcon
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            if showIcon {
                Image(systemName: DesignSystem.Icons.priorityFlag)
                    .font(DesignSystem.Typography.caption2)
            }

            Text(priority.shortName)
                .font(DesignSystem.Typography.caption2)
                .fontWeight(.medium)
        }
        .padding(.horizontal, DesignSystem.Spacing.small)
        .padding(.vertical, DesignSystem.Spacing.xSmall)
        .background(
            Capsule()
                .fill(priorityColor.opacity(0.15))
        )
        .foregroundStyle(priorityColor)
    }

    // MARK: - Computed Properties

    /// 优先级对应的颜色
    private var priorityColor: Color {
        .priority(priority)
    }
}

// MARK: - Previews

#Preview("Priority Badges") {
    VStack(spacing: DesignSystem.Spacing.medium) {
        PriorityBadge(priority: .high)
        PriorityBadge(priority: .medium)
        PriorityBadge(priority: .low)
        PriorityBadge(priority: .high, showIcon: false)
    }
    .padding()
}
