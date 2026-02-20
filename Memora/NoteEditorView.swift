//
//  NoteEditorView.swift
//  Memora
//
//  Created by Claude Code
//  Copyright © 2025 Memora. All rights reserved.
//

import SwiftUI
import SwiftData

/// 记事编辑视图 - EVA 主题版本
/// 支持创建新记事和编辑现有记事
/// 核心功能：多任务项（Checklist）的增删改查
/// EVA 设计：NERV 操作界面风格
struct NoteEditorView: View {
    // MARK: - Types

    enum Mode {
        case create
        case edit(Note)

        var title: String {
            switch self {
            case .create: return "INITIALIZE MISSION"
            case .edit: return "CONFIGURE MISSION"
            }
        }

        var saveButtonTitle: String {
            switch self {
            case .create: return "CREATE"
            case .edit: return "SAVE"
            }
        }
    }

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // MARK: - Properties

    let mode: Mode

    // MARK: - State

    @State private var title: String
    @State private var content: String
    @State private var priority: NotePriority
    @State private var items: [ChecklistItem]

    @State private var newItemText: String = ""
    @State private var showDiscardAlert = false

    @FocusState private var isTitleFocused: Bool
    @FocusState private var isNewItemFocused: Bool

    // 用于编辑模式
    private var existingNote: Note?

    // MARK: - Computed Properties

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var hasChanges: Bool {
        switch mode {
        case .create:
            return !title.isEmpty || !content.isEmpty || !items.isEmpty
        case .edit(let note):
            return title != note.title ||
                   content != note.content ||
                   priority != note.priority ||
                   items.count != note.items.count
        }
    }

    private var repository: NoteRepository {
        NoteRepository(context: modelContext)
    }

    // MARK: - Initialization

    init(mode: Mode) {
        self.mode = mode

        switch mode {
        case .create:
            _title = State(initialValue: "")
            _content = State(initialValue: "")
            _priority = State(initialValue: .medium)
            _items = State(initialValue: [])
            existingNote = nil

        case .edit(let note):
            _title = State(initialValue: note.title)
            _content = State(initialValue: note.content)
            _priority = State(initialValue: note.priority)
            _items = State(initialValue: note.items)
            existingNote = note
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // EVA 背景
                evaBackground

                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.large) {
                        // 标题输入区
                        titleSection

                        // 优先级选择
                        prioritySection

                        // 备注内容
                        contentSection

                        // 任务清单区域（核心功能）
                        checklistSection
                    }
                    .padding()
                }
            }
            .navigationTitle(mode.title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                toolbarContent
            }
            .onAppear {
                if case .create = mode {
                    isTitleFocused = true
                }
            }
            .alert("DISCARD CHANGES", isPresented: $showDiscardAlert) {
                Button("CANCEL", role: .cancel) {}
                Button("DISCARD", role: .destructive) {
                    dismiss()
                }
            } message: {
                Text("You have unsaved changes. Are you sure you want to discard them?")
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

    /// 标题输入区
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            // Section Header
            HStack {
                Text("SUBJECT")
                    .font(DesignSystem.Typography.caption2)
                    .foregroundStyle(DesignSystem.Colors.accent)

                Spacer()

                Text("REQUIRED")
                    .font(DesignSystem.Typography.caption2)
                    .foregroundStyle(DesignSystem.Colors.alert.opacity(0.6))
            }

            // 输入框
            TextField("Mission Title", text: $title, axis: .vertical)
                .font(DesignSystem.Typography.title3)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
                .focused($isTitleFocused)
                .lineLimit(2...3)
                .padding(DesignSystem.Spacing.medium)
                .background(DesignSystem.Colors.tertiaryBackground)
                .cornerRadius(DesignSystem.CornerRadius.small)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .stroke(
                            isTitleFocused ?
                                DesignSystem.Colors.primary :
                                DesignSystem.Colors.primary.opacity(0.3),
                            lineWidth: isTitleFocused ? 2 : 1
                        )
                )
        }
    }

    /// 优先级选择区
    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("PRIORITY LEVEL")
                .font(DesignSystem.Typography.caption2)
                .foregroundStyle(DesignSystem.Colors.accent)

            HStack(spacing: DesignSystem.Spacing.small) {
                ForEach(NotePriority.allCases) { p in
                    Button {
                        withAnimation(DesignSystem.Animation.fast) {
                            priority = p
                        }
                    } label: {
                        HStack {
                            Image(systemName: DesignSystem.Icons.priorityFlag)
                                .font(.caption)

                            Text(p.localizedName)
                                .font(DesignSystem.Typography.caption)
                        }
                        .padding(.horizontal, DesignSystem.Spacing.medium)
                        .padding(.vertical, DesignSystem.Spacing.small)
                        .background(
                            priority == p ?
                                Color.priority(p) :
                                DesignSystem.Colors.tertiaryBackground
                        )
                        .foregroundStyle(
                            priority == p ?
                                Color.black :
                                Color.priority(p)
                        )
                        .cornerRadius(DesignSystem.CornerRadius.small)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                                .stroke(Color.priority(p), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    /// 内容/备注区
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("ADDITIONAL DATA")
                .font(DesignSystem.Typography.caption2)
                .foregroundStyle(DesignSystem.Colors.accent)

            TextField("Notes or description (optional)", text: $content, axis: .vertical)
                .font(DesignSystem.Typography.body)
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .lineLimit(3...6)
                .padding(DesignSystem.Spacing.medium)
                .background(DesignSystem.Colors.tertiaryBackground)
                .cornerRadius(DesignSystem.CornerRadius.small)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .stroke(
                            DesignSystem.Colors.textTertiary.opacity(0.3),
                            lineWidth: 1
                        )
                )
        }
    }

    /// 任务清单区（核心功能）
    private var checklistSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            // Header
            HStack {
                Text("OPERATIONS CHECKLIST")
                    .font(DesignSystem.Typography.caption2)
                    .foregroundStyle(DesignSystem.Colors.accent)

                Spacer()

                Text("[\(items.count) ITEMS]")
                    .font(DesignSystem.Typography.digital)
                    .foregroundStyle(DesignSystem.Colors.textTertiary)
            }

            // 现有任务列表
            if !items.isEmpty {
                VStack(spacing: DesignSystem.Spacing.xSmall) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        checklistItemRow(item: item, index: index)
                    }
                }
            }

            // 添加新任务项输入框
            addNewItemRow
        }
        .padding(DesignSystem.Spacing.medium)
        .background(
            DesignSystem.Colors.secondaryBackground.opacity(0.5)
        )
        .cornerRadius(DesignSystem.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .stroke(
                    DesignSystem.Colors.accent.opacity(0.2),
                    lineWidth: 1
                )
        )
    }

    /// 单个任务项行
    private func checklistItemRow(item: ChecklistItem, index: Int) -> some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            // 完成状态按钮
            Button {
                withAnimation(DesignSystem.Animation.spring) {
                    items[index].toggle()
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

            // 任务内容文本（可编辑）
            TextField("Task", text: Binding(
                get: { item.content },
                set: { newValue in
                    items[index].content = newValue
                }
            ))
            .font(DesignSystem.Typography.body)
            .foregroundStyle(
                item.isCompleted ?
                    DesignSystem.Colors.textTertiary :
                    DesignSystem.Colors.textPrimary
            )
            .strikethrough(item.isCompleted)

            // 删除按钮
            Button {
                withAnimation(DesignSystem.Animation.standard) {
                    _ = items.remove(at: index)
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(DesignSystem.Colors.alert.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Colors.tertiaryBackground)
        .cornerRadius(DesignSystem.CornerRadius.small)
    }

    /// 添加新任务项行
    private var addNewItemRow: some View {
        HStack {
            Image(systemName: "plus.circle")
                .foregroundStyle(DesignSystem.Colors.primary)

            TextField("Add new operation...", text: $newItemText)
                .font(DesignSystem.Typography.body)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
                .focused($isNewItemFocused)
                .onSubmit {
                    addNewItem()
                }

            if !newItemText.isEmpty {
                Button("ADD") {
                    addNewItem()
                }
                .font(DesignSystem.Typography.caption)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Colors.primary)
                .buttonStyle(.plain)
            }
        }
        .padding(DesignSystem.Spacing.small)
        .background(
            DesignSystem.Colors.tertiaryBackground.opacity(0.5)
        )
        .cornerRadius(DesignSystem.CornerRadius.small)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .stroke(
                    style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                )
                .foregroundStyle(DesignSystem.Colors.primary.opacity(0.3))
        )
    }

    /// 工具栏
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("ABORT") {
                handleCancel()
            }
            .foregroundStyle(DesignSystem.Colors.alert)
        }

        ToolbarItem(placement: .confirmationAction) {
            Button(mode.saveButtonTitle) {
                saveNote()
            }
            .foregroundStyle(DesignSystem.Colors.primary)
            .fontWeight(.bold)
            .disabled(!isValid)
        }
    }

    // MARK: - Actions

    /// 添加新任务项
    private func addNewItem() {
        let trimmed = newItemText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        withAnimation(DesignSystem.Animation.standard) {
            let newItem = ChecklistItem(content: trimmed)
            items.append(newItem)
            newItemText = ""
            isNewItemFocused = true
        }
    }

    /// 处理取消操作
    private func handleCancel() {
        if hasChanges {
            showDiscardAlert = true
        } else {
            dismiss()
        }
    }

    /// 保存记事
    private func saveNote() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        do {
            switch mode {
            case .create:
                // 创建新记事
                let newNote = Note(
                    title: trimmedTitle,
                    content: content,
                    priority: priority
                )

                // 添加任务清单项
                newNote.items = items

                try repository.create(note: newNote)

            case .edit(let note):
                // 更新现有记事
                note.title = trimmedTitle
                note.content = content
                note.priority = priority
                note.updatedAt = Date()

                // 删除旧的任务项（SwiftData 会自动处理）
                note.items.removeAll()

                // 添加新的任务项
                note.items = items

                try modelContext.save()
            }

            dismiss()
        } catch {
            print("⚠️ Save failed: \(error)")
        }
    }
}

// MARK: - Previews

#Preview("Create Note") {
    NoteEditorPreviewFactory.create
}

#Preview("Edit Note with Checklist") {
    NoteEditorPreviewFactory.editWithChecklist
}

private enum NoteEditorPreviewFactory {
    static var create: some View {
        NoteEditorView(mode: .create)
            .modelContainer(for: [Note.self, ChecklistItem.self], inMemory: true)
    }

    static var editWithChecklist: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: Note.self, ChecklistItem.self,
            configurations: config
        )

        let note: Note = {
            let note = Note(
                title: "EVA UNIT-01 ACTIVATION TEST",
                content: "Pre-combat synchronization check",
                priority: .high
            )

            note.items = [
                ChecklistItem(content: "Initialize pilot interface", isCompleted: true),
                ChecklistItem(content: "Run system diagnostics", isCompleted: false),
                ChecklistItem(content: "Execute combat simulation", isCompleted: false)
            ]

            return note
        }()

        container.mainContext.insert(note)

        return NoteEditorView(mode: .edit(note))
            .modelContainer(container)
    }
}
