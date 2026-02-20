//
//  NoteDetailView.swift
//  Memora
//
//  Created by Claude Code
//  Copyright © 2025 Memora. All rights reserved.
//

import SwiftUI
import SwiftData

/// 记事详情视图 - EVA 主题版本
/// 展示记事的完整信息，支持查看和编辑任务清单
/// EVA 设计：NERV 数据面板风格
struct NoteDetailView: View {
    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // MARK: - Properties

    let note: Note

    // MARK: - State

    @State private var showEditSheet = false
    @State private var showDeleteAlert = false

    // MARK: - Computed Properties

    private var repository: NoteRepository {
        NoteRepository(context: modelContext)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // EVA 背景
                evaBackground

                ScrollView {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
                        // 标题区域
                        titleSection

                        // 元数据区域
                        metadataSection

                        // 任务清单区域（如果有）
                        if note.hasChecklist {
                            checklistSection
                        }

                        // 内容区域（如果有）
                        if note.hasContent {
                            contentSection
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("MISSION DETAILS")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $showEditSheet) {
                NoteEditorView(mode: .edit(note))
            }
            .alert("DELETE MISSION", isPresented: $showDeleteAlert) {
                Button("CANCEL", role: .cancel) {}
                Button("DELETE", role: .destructive) {
                    deleteNote()
                }
            } message: {
                Text("This action cannot be undone. All checklist items will be deleted.")
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Subviews

    /// EVA 风格背景
    private var evaBackground: some View {
        DesignSystem.Colors.background
            .ignoresSafeArea()
    }

    /// 标题区域
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            // 优先级色条装饰
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.priority(note.priority))
                    .frame(width: 6, height: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(note.title)
                        .font(DesignSystem.Typography.title2)
                        .foregroundStyle(
                            note.completed ?
                                DesignSystem.Colors.textSecondary :
                                DesignSystem.Colors.primary
                        )
                        .strikethrough(note.completed)

                    HStack {
                        Image(systemName: DesignSystem.Icons.priorityFlag)
                            .font(.caption2)
                        Text(note.priority.localizedName.uppercased())
                            .font(DesignSystem.Typography.caption2)
                    }
                    .foregroundStyle(Color.priority(note.priority))
                }
                .padding(.leading, DesignSystem.Spacing.medium)

                Spacer()

                // 完成状态按钮
                completionButton
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Colors.secondaryBackground.opacity(0.5))
        .cornerRadius(DesignSystem.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .stroke(Color.priority(note.priority).opacity(0.3), lineWidth: 1)
        )
    }

    /// 元数据区域
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Text("METADATA")
                .font(DesignSystem.Typography.caption2)
                .foregroundStyle(DesignSystem.Colors.accent)

            VStack(spacing: DesignSystem.Spacing.small) {
                // 创建时间
                metadataRow(
                    icon: DesignSystem.Icons.calendar,
                    label: "CREATED",
                    value: formattedDateTime(note.createdAt)
                )

                // 更新时间
                if note.updatedAt != note.createdAt {
                    metadataRow(
                        icon: DesignSystem.Icons.clock,
                        label: "UPDATED",
                        value: formattedDateTime(note.updatedAt)
                    )
                }

                // 进度（如果有任务清单）
                if note.hasChecklist {
                    metadataRow(
                        icon: DesignSystem.Icons.progress,
                        label: "PROGRESS",
                        value: "\(Int(note.progress * 100))% [\(note.completedItemsCount)/\(note.totalItemsCount)]"
                    )
                }
            }
            .padding(DesignSystem.Spacing.medium)
            .background(DesignSystem.Colors.tertiaryBackground.opacity(0.5))
            .cornerRadius(DesignSystem.CornerRadius.small)
        }
    }

    /// 元数据行
    private func metadataRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(DesignSystem.Colors.accent)
                .frame(width: 20)

            Text(label)
                .font(DesignSystem.Typography.caption)
                .foregroundStyle(DesignSystem.Colors.textSecondary)

            Spacer()

            Text(value)
                .font(DesignSystem.Typography.digital)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
        }
    }

    /// 任务清单区域
    private var checklistSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            HStack {
                Text("OPERATIONS CHECKLIST")
                    .font(DesignSystem.Typography.caption2)
                    .foregroundStyle(DesignSystem.Colors.accent)

                Spacer()

                Text("[\(note.totalItemsCount) ITEMS]")
                    .font(DesignSystem.Typography.digital)
                    .foregroundStyle(DesignSystem.Colors.textTertiary)
            }

            VStack(spacing: DesignSystem.Spacing.xSmall) {
                ForEach(note.items) { item in
                    checklistItemRow(item: item)
                }
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Colors.secondaryBackground.opacity(0.3))
        .cornerRadius(DesignSystem.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .stroke(DesignSystem.Colors.accent.opacity(0.2), lineWidth: 1)
        )
    }

    /// 单个任务项行（只读，可切换完成状态）
    private func checklistItemRow(item: ChecklistItem) -> some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            // 完成状态按钮
            Button {
                withAnimation(DesignSystem.Animation.spring) {
                    #if os(iOS)
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    #endif

                    item.toggle()
                    try? modelContext.save()
                }
            } label: {
                Image(systemName: item.isCompleted ? DesignSystem.Icons.checked : DesignSystem.Icons.unchecked)
                    .font(.body)
                    .foregroundStyle(
                        item.isCompleted ?
                            DesignSystem.Colors.primary :
                            DesignSystem.Colors.textTertiary
                    )
            }
            .buttonStyle(.plain)

            // 任务内容
            Text(item.content)
                .font(DesignSystem.Typography.body)
                .foregroundStyle(
                    item.isCompleted ?
                        DesignSystem.Colors.textTertiary :
                        DesignSystem.Colors.textPrimary
                )
                .strikethrough(item.isCompleted)

            Spacer()
        }
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Colors.tertiaryBackground.opacity(0.5))
        .cornerRadius(DesignSystem.CornerRadius.small)
    }

    /// 内容区域
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Text("ADDITIONAL DATA")
                .font(DesignSystem.Typography.caption2)
                .foregroundStyle(DesignSystem.Colors.accent)

            Text(note.content)
                .font(DesignSystem.Typography.body)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
                .textSelection(.enabled)
                .padding(DesignSystem.Spacing.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DesignSystem.Colors.tertiaryBackground.opacity(0.3))
                .cornerRadius(DesignSystem.CornerRadius.small)
        }
    }

    /// 完成状态按钮
    private var completionButton: some View {
        Button {
            toggleCompletion()
        } label: {
            Image(systemName: note.completed ? "checkmark.square.fill" : "square")
                .font(.largeTitle)
                .foregroundStyle(
                    note.completed ?
                        DesignSystem.Colors.primary :
                        DesignSystem.Colors.textTertiary
                )
        }
        .buttonStyle(.plain)
    }

    /// 工具栏内容
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("CLOSE") {
                dismiss()
            }
            .foregroundStyle(DesignSystem.Colors.textSecondary)
        }

        ToolbarItem(placement: .primaryAction) {
            Menu {
                Button {
                    showEditSheet = true
                } label: {
                    Label("EDIT", systemImage: DesignSystem.Icons.edit)
                }

                Divider()

                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Label("DELETE", systemImage: DesignSystem.Icons.delete)
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(DesignSystem.Colors.primary)
            }
        }
    }

    // MARK: - Actions

    /// 切换完成状态
    private func toggleCompletion() {
        withAnimation(DesignSystem.Animation.spring) {
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            #endif

            do {
                try repository.toggleCompleted(note)
            } catch {
                print("⚠️ Toggle completion failed: \(error)")
            }
        }
    }

    /// 删除记事
    private func deleteNote() {
        do {
            try repository.delete(note)
            dismiss()
        } catch {
            print("⚠️ Delete failed: \(error)")
        }
    }

    // MARK: - Helpers

    /// 格式化时间 - 完整的年月日时分
    private func formattedDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Previews

#Preview("Note Detail - With Checklist") {
    NoteDetailPreviewFactory.withChecklist
}

#Preview("Note Detail - Simple") {
    NoteDetailPreviewFactory.simple
}

private enum NoteDetailPreviewFactory {
    static var withChecklist: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: Note.self, ChecklistItem.self,
            configurations: config
        )

        let note: Note = {
            let note = Note(
                title: "EVA UNIT-01 ACTIVATION SEQUENCE",
                content: "Critical mission - Angel threat detected. All personnel on standby.",
                priority: .high
            )

            note.items = [
                ChecklistItem(content: "Initialize LCL injection", isCompleted: true),
                ChecklistItem(content: "Activate neural connection", isCompleted: true),
                ChecklistItem(content: "Run synchronization test", isCompleted: false),
                ChecklistItem(content: "Deploy to combat zone", isCompleted: false)
            ]

            return note
        }()

        container.mainContext.insert(note)

        return NoteDetailView(note: note)
            .modelContainer(container)
    }

    static var simple: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: Note.self, ChecklistItem.self,
            configurations: config
        )

        let note = Note(
            title: "NERV BRIEFING",
            content: "Weekly status meeting with all department heads.",
            priority: .medium
        )

        container.mainContext.insert(note)

        return NoteDetailView(note: note)
            .modelContainer(container)
    }
}
