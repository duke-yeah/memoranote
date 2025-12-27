//
//  ChecklistItem.swift
//  Memora
//
//  Created by Claude Code
//  Copyright © 2025 Memora. All rights reserved.
//

import Foundation
import SwiftData

/// 检查清单项模型
/// 表示 Note 中的单个可勾选任务项
/// 支持多个 ChecklistItem 组成一个任务清单
@Model
final class ChecklistItem {
    // MARK: - Properties

    /// 唯一标识符
    var id: UUID

    /// 任务内容
    var content: String

    /// 是否已完成
    var isCompleted: Bool

    /// 创建时间
    var createdAt: Date

    /// 更新时间
    var updatedAt: Date

    // MARK: - Initialization

    /// 创建新的检查清单项
    /// - Parameters:
    ///   - content: 任务内容
    ///   - isCompleted: 是否已完成，默认为 false
    init(content: String, isCompleted: Bool = false) {
        self.id = UUID()
        self.content = content
        self.isCompleted = isCompleted
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Methods

    /// 切换完成状态
    func toggle() {
        isCompleted.toggle()
        updatedAt = Date()
    }
}
