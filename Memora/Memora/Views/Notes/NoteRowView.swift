//
//  NoteRowView.swift
//  Memora
//
//  Created by Claude Code
//  Copyright © 2025 Memora. All rights reserved.
//

import SwiftUI
import SwiftData

/// 记事列表行视图 - EVA 主题版本
/// 展示单个记事的概要信息，包括标题、任务进度、完整时间等
/// EVA 设计元素：优先级色条、数字进度、等宽字体
struct NoteRowView: View {
    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext

    // MARK: - Properties

    let note: Note
    let onToggleComplete: (Note) -> Void

    // MARK: - Body

    var body: some View {
        HStack(spacing: 0) {
            // 左侧：优先级色条 (EVA 风格装饰元素)
            Rectangle()
                .fill(Color.priority(note.priority))
                .frame(width: 4)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                // 顶部：标题和状态
                HStack(alignment: .top) {
                    Text(note.title)
                        .font(DesignSystem.Typography.title3)
                        .foregroundStyle(
                            note.completed ?
                                DesignSystem.Colors.textTertiary :
                                DesignSystem.Colors.primary
                        )
                        .strikethrough(note.completed)
                        .lineLimit(2)

                    Spacer()

                    // 进度指示器 (仅在有任务清单时显示)
                    if note.hasChecklist {
                        progressIndicator
                    }
                }

                // 中部：任务清单预览 或 内容预览
                if note.hasChecklist {
                    checklistPreview
                } else if note.hasContent {
                    contentPreview
                }

                // 底部：完整时间显示 + 完成按钮
                HStack {
                    Image(systemName: DesignSystem.Icons.clock)
                        .font(.caption2)
                        .foregroundStyle(DesignSystem.Colors.accent)

                    Text(formattedTime)
                        .font(DesignSystem.Typography.digital)
                        .foregroundStyle(DesignSystem.Colors.textSecondary)

                    Spacer()

                    // 完成状态按钮
                    completionButton
                }
            }
            .padding(DesignSystem.Spacing.medium)
            .background(
                DesignSystem.Colors.secondaryBackground
                    .opacity(note.completed ? 0.5 : 0.8)
            )
            .overlay(
                // EVA 风格边框：优先级色半透明描边
                Rectangle()
                    .stroke(
                        Color.priority(note.priority).opacity(0.3),
                        lineWidth: 1
                    )
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        .padding(.vertical, DesignSystem.Spacing.xSmall)
    }

    // MARK: - Subviews

    /// 进度指示器
    private var progressIndicator: some View {
        HStack(spacing: 4) {
            Image(systemName: DesignSystem.Icons.progress)
                .font(.caption2)

            Text("\(Int(note.progress * 100))%")
                .font(DesignSystem.Typography.digital)

            Text("[\(note.completedItemsCount)/\(note.totalItemsCount)]")
                .font(DesignSystem.Typography.caption2)
        }
        .foregroundStyle(
            note.progress == 1.0 ?
                DesignSystem.Colors.primary :
                DesignSystem.Colors.accent
        )
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            DesignSystem.Colors.tertiaryBackground
        )
        .clipShape(Capsule())
    }

    /// 任务清单预览
    private var checklistPreview: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(note.items.prefix(3)) { item in
                HStack(spacing: 4) {
                    // 可点击的完成状态按钮
                    Button {
                        toggleItemCompletion(item: item)
                    } label: {
                        Image(systemName: item.isCompleted ? DesignSystem.Icons.checked : DesignSystem.Icons.unchecked)
                            .font(.caption2)
                            .foregroundStyle(
                                item.isCompleted ?
                                    DesignSystem.Colors.primary :
                                    DesignSystem.Colors.textTertiary
                            )
                    }
                    .buttonStyle(.plain)

                    Text(item.content)
                        .font(DesignSystem.Typography.caption)
                        .foregroundStyle(
                            item.isCompleted ?
                                DesignSystem.Colors.textTertiary :
                                DesignSystem.Colors.textSecondary
                        )
                        .strikethrough(item.isCompleted)
                        .lineLimit(1)
                }
            }

            // 如果有更多任务项，显示省略号
            if note.totalItemsCount > 3 {
                Text("... +\(note.totalItemsCount - 3) MORE")
                    .font(DesignSystem.Typography.caption2)
                    .foregroundStyle(DesignSystem.Colors.textTertiary)
                    .padding(.leading, 18)
            }
        }
    }

    /// 内容预览
    private var contentPreview: some View {
        Text(note.content)
            .font(DesignSystem.Typography.callout)
            .foregroundStyle(DesignSystem.Colors.textSecondary)
            .lineLimit(2)
            .opacity(note.completed ? 0.6 : 0.8)
    }

    /// 完成状态按钮
    private var completionButton: some View {
        Button {
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            #endif

            withAnimation(DesignSystem.Animation.spring) {
                onToggleComplete(note)
            }
        } label: {
            Image(systemName: note.completed ? "checkmark.square.fill" : "square")
                .font(.title3)
                .foregroundStyle(
                    note.completed ?
                        DesignSystem.Colors.primary :
                        DesignSystem.Colors.textTertiary
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    /// 切换任务项的完成状态
    private func toggleItemCompletion(item: ChecklistItem) {
        withAnimation(DesignSystem.Animation.spring) {
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            #endif

            item.toggle()
            try? modelContext.save()
        }
    }

    // MARK: - Computed Properties

    /// 格式化的时间 - 完整的年月日时分显示
    /// 格式：YYYY-MM-DD HH:mm
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: note.createdAt)
    }
}

// MARK: - Previews

#Preview("Note Row - With Checklist") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Note.self, ChecklistItem.self,
        configurations: config
    )

    let note = Note(
        title: "EVA SYSTEM TEST",
        content: "NERV Interface Design",
        priority: .high
    )

    // 添加任务清单
    note.items = [
        ChecklistItem(content: "Initialize Unit-01", isCompleted: true),
        ChecklistItem(content: "Synchronization Test", isCompleted: true),
        ChecklistItem(content: "Combat Simulation", isCompleted: false),
        ChecklistItem(content: "Final Approval", isCompleted: false)
    ]

    container.mainContext.insert(note)

    return VStack {
        NoteRowView(note: note) { _ in }
            .modelContainer(container)
            .padding()
            .background(DesignSystem.Colors.background)
    }
}

#Preview("Note Row - Simple") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Note.self, ChecklistItem.self,
        configurations: config
    )

    let note = Note(
        title: "MISSION BRIEFING",
        content: "Prepare for Angel attack scenario",
        priority: .medium
    )

    container.mainContext.insert(note)

    return VStack {
        NoteRowView(note: note) { _ in }
            .modelContainer(container)
            .padding()
            .background(DesignSystem.Colors.background)
    }
}
