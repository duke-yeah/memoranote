//
//  Note.swift
//  Memora
//
//  Created by Claude Code
//  Copyright © 2025 Memora. All rights reserved.
//

import Foundation
import SwiftData

/// 记事数据模型 - EVA 主题版本
/// 使用 SwiftData 实现本地持久化，支持 iOS 17+ 和 macOS 14+
/// 新增功能：支持多任务项清单（ChecklistItem）
@Model
class Note {
    var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var completed: Bool
    var priorityRawValue: String
    var dueDate: Date?

    /// 一对多关系：任务清单项
    /// 使用 cascade 删除规则，删除 Note 时自动删除所有关联的 ChecklistItem
    @Relationship(deleteRule: .cascade)
    var items: [ChecklistItem] = []

    /// 优先级计算属性
    var priority: NotePriority {
        get {
            NotePriority(rawValue: priorityRawValue) ?? .medium
        }
        set {
            priorityRawValue = newValue.rawValue
        }
    }

    init(
        id: UUID = UUID(),
        title: String,
        content: String = "",
        priority: NotePriority = .medium,
        completed: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        dueDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.completed = completed
        self.priorityRawValue = priority.rawValue
        self.dueDate = dueDate
    }

    /// 是否有内容
    var hasContent: Bool {
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// 是否过期（如果设置了截止日期）
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return !completed && dueDate < Date()
    }

    // MARK: - Checklist Progress

    /// 任务清单总进度 (0.0 - 1.0)
    /// - 如果没有子任务项，返回整体完成状态 (0.0 或 1.0)
    /// - 如果有子任务项，返回已完成项的百分比
    var progress: Double {
        guard !items.isEmpty else {
            return completed ? 1.0 : 0.0
        }

        let completedCount = items.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(items.count)
    }

    /// 已完成的任务项数量
    var completedItemsCount: Int {
        items.filter { $0.isCompleted }.count
    }

    /// 任务清单总数量
    var totalItemsCount: Int {
        items.count
    }

    /// 是否有任务清单
    var hasChecklist: Bool {
        !items.isEmpty
    }
}
