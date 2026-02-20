//
//  NoteRepository.swift
//  Memora
//
//  Created by Claude Code
//  Copyright © 2025 Memora. All rights reserved.
//

import Foundation
import SwiftData

/// 记事数据访问层
/// 封装所有与 Note 相关的数据操作，遵循 Repository 模式
@MainActor
final class NoteRepository {
    // MARK: - Properties

    private let context: ModelContext

    // MARK: - Initialization

    /// 初始化 Repository
    /// - Parameter context: SwiftData 的 ModelContext
    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Create

    /// 创建新的记事
    /// - Parameters:
    ///   - title: 标题
    ///   - content: 内容，默认为空
    ///   - priority: 优先级，默认为中等
    ///   - dueDate: 截止日期，默认为 nil
    /// - Returns: 创建的 Note 对象
    /// - Throws: 数据库保存错误
    @discardableResult
    func create(
        title: String,
        content: String = "",
        priority: NotePriority = .medium,
        dueDate: Date? = nil
    ) throws -> Note {
        let note = Note(
            title: title,
            content: content,
            priority: priority,
            dueDate: dueDate
        )
        context.insert(note)
        try context.save()
        return note
    }

    /// 创建新的记事（直接传入 Note 对象）
    /// - Parameter note: 已创建的 Note 对象（包含任务清单项）
    /// - Throws: 数据库保存错误
    /// - Note: 用于支持带有 ChecklistItem 的复杂创建场景
    @discardableResult
    func create(note: Note) throws -> Note {
        context.insert(note)
        try context.save()
        return note
    }

    // MARK: - Update

    /// 更新记事的内容
    /// - Parameters:
    ///   - note: 要更新的 Note 对象
    ///   - title: 新标题
    ///   - content: 新内容
    ///   - priority: 新优先级
    ///   - dueDate: 新截止日期
    /// - Throws: 数据库保存错误
    func update(
        _ note: Note,
        title: String,
        content: String,
        priority: NotePriority,
        dueDate: Date?
    ) throws {
        note.title = title
        note.content = content
        note.priority = priority
        note.dueDate = dueDate
        note.updatedAt = .now
        try context.save()
    }

    /// 切换记事的完成状态
    /// - Parameters:
    ///   - note: 要更新的 Note 对象
    ///   - completed: 新的完成状态
    /// - Throws: 数据库保存错误
    func setCompleted(_ note: Note, completed: Bool) throws {
        note.completed = completed
        note.updatedAt = .now
        try context.save()
    }

    /// 切换记事的完成状态（布尔值取反）
    /// - Parameter note: 要更新的 Note 对象
    /// - Throws: 数据库保存错误
    func toggleCompleted(_ note: Note) throws {
        try setCompleted(note, completed: !note.completed)
    }

    // MARK: - Delete

    /// 删除记事
    /// - Parameter note: 要删除的 Note 对象
    /// - Throws: 数据库保存错误
    func delete(_ note: Note) throws {
        context.delete(note)
        try context.save()
    }

    /// 批量删除记事
    /// - Parameter notes: 要删除的 Note 数组
    /// - Throws: 数据库保存错误
    func deleteAll(_ notes: [Note]) throws {
        for note in notes {
            context.delete(note)
        }
        try context.save()
    }

    // MARK: - Query Helpers

    /// 获取所有未完成的记事数量
    /// - Returns: 未完成记事的数量
    func uncompletedCount() -> Int {
        let descriptor = FetchDescriptor<Note>(
            predicate: #Predicate { !$0.completed }
        )
        return (try? context.fetchCount(descriptor)) ?? 0
    }

    /// 获取指定优先级的记事数量
    /// - Parameter priority: 优先级
    /// - Returns: 该优先级的记事数量
    func count(for priority: NotePriority) -> Int {
        let descriptor = FetchDescriptor<Note>(
            predicate: #Predicate { $0.priority == priority }
        )
        return (try? context.fetchCount(descriptor)) ?? 0
    }
}
