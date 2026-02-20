//
//  NoteListView.swift
//  Memora
//
//  Created by Claude Code
//  Copyright © 2025 Memora. All rights reserved.
//

import SwiftUI
import SwiftData

/// 时间筛选范围
enum TimeFilter: String, CaseIterable, Identifiable {
    case all = "全部"
    case today = "今天"
    case week = "最近7天"
    case month = "最近30天"

    var id: String { rawValue }

    /// 获取起始日期
    var startDate: Date? {
        let calendar = Calendar.current
        let now = Date()

        switch self {
        case .all:
            return nil
        case .today:
            return calendar.startOfDay(for: now)
        case .week:
            return calendar.date(byAdding: .day, value: -7, to: now)
        case .month:
            return calendar.date(byAdding: .day, value: -30, to: now)
        }
    }
}

/// 记事列表主视图 - EVA 主题版本
/// 展示所有记事，支持搜索、筛选、排序等功能
/// EVA 设计：NERV 指挥室风格的深色背景、科技感界面
struct NoteListView: View {
    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext

    // MARK: - State

    @State private var searchText = ""
    @State private var selectedPriority: NotePriority?
    @State private var selectedTimeFilter: TimeFilter = .all
    @State private var showAddSheet = false
    @State private var showVoiceInputSheet = false
    @State private var selectedNote: Note?
    @State private var voiceErrorMessage: String?

    // MARK: - Query

    /// 动态查询所有记事
    /// 排序规则：创建时间倒序
    @Query(sort: \Note.createdAt, order: .reverse)
    private var notes: [Note]

    // MARK: - Computed Properties

    /// 过滤后的记事列表
    private var filteredNotes: [Note] {
        notes.filter { note in
            // 搜索过滤
            let matchesSearch = searchText.isEmpty ||
                note.title.localizedStandardContains(searchText) ||
                note.content.localizedStandardContains(searchText)

            // 优先级过滤
            let matchesPriority = selectedPriority == nil || note.priority == selectedPriority

            // 时间过滤
            let matchesTime: Bool
            if let startDate = selectedTimeFilter.startDate {
                matchesTime = note.createdAt >= startDate
            } else {
                matchesTime = true // 全部时间
            }

            return matchesSearch && matchesPriority && matchesTime
        }
    }

    /// Repository 实例
    private var repository: NoteRepository {
        NoteRepository(context: modelContext)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // EVA 全局背景
                evaBackground

                if filteredNotes.isEmpty {
                    emptyStateView
                } else {
                    noteList
                }
            }
            .navigationTitle("MEMORA")
            .searchable(text: $searchText, prompt: "SEARCH MISSIONS...")
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $showAddSheet) {
                NoteEditorView(mode: .create)
            }
            .sheet(isPresented: $showVoiceInputSheet) {
                VoiceInputView { transcript in
                    createNoteFromVoice(transcript)
                }
            }
            .sheet(item: $selectedNote) { note in
                NoteDetailView(note: note)
            }
            .alert("VOICE SAVE FAILED", isPresented: Binding(
                get: { voiceErrorMessage != nil },
                set: { if !$0 { voiceErrorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(voiceErrorMessage ?? "Unknown error")
            }
        }
        .preferredColorScheme(.dark) // 强制深色模式
    }

    // MARK: - Subviews

    /// EVA 风格背景
    private var evaBackground: some View {
        // 主背景色
        DesignSystem.Colors.background
            .ignoresSafeArea()
    }

    /// 记事列表
    private var noteList: some View {
        List {
            ForEach(filteredNotes) { note in
                NoteRowView(note: note) { targetNote in
                    toggleCompletion(for: targetNote)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedNote = note
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        deleteNote(note)
                    } label: {
                        Label("DELETE", systemImage: DesignSystem.Icons.delete)
                    }
                    .tint(DesignSystem.Colors.alert)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    /// 空状态视图 - EVA 风格
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            // 科技感图标
            Image(systemName: "cube.transparent")
                .font(.system(size: 72))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.primary,
                            DesignSystem.Colors.secondary
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: DesignSystem.Spacing.small) {
                Text("NO DATA RECORDED")
                    .font(DesignSystem.Typography.title2)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)

                if !searchText.isEmpty {
                    Text("SEARCH: \"\(searchText)\" - NO RESULTS")
                        .font(DesignSystem.Typography.caption)
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                } else if selectedPriority != nil {
                    Text("NO MISSIONS AT THIS PRIORITY LEVEL")
                        .font(DesignSystem.Typography.caption)
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                } else if selectedTimeFilter != .all {
                    Text("NO MISSIONS IN \(selectedTimeFilter.rawValue.uppercased())")
                        .font(DesignSystem.Typography.caption)
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                } else {
                    Text("TAP [+] TO INITIALIZE NEW MISSION")
                        .font(DesignSystem.Typography.caption)
                        .foregroundStyle(DesignSystem.Colors.accent)
                }
            }

            // 装饰线条
            HStack(spacing: DesignSystem.Spacing.small) {
                Rectangle()
                    .fill(DesignSystem.Colors.primary)
                    .frame(width: 40, height: 2)
                Rectangle()
                    .fill(DesignSystem.Colors.accent)
                    .frame(width: 20, height: 2)
                Rectangle()
                    .fill(DesignSystem.Colors.secondary)
                    .frame(width: 60, height: 2)
            }
        }
    }

    /// 工具栏内容
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        // 添加按钮
        ToolbarItem(placement: .primaryAction) {
            Button {
                showVoiceInputSheet = true
            } label: {
                Image(systemName: "mic.fill")
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Colors.accent)
            }
        }

        // 添加按钮
        ToolbarItem(placement: .primaryAction) {
            Button {
                showAddSheet = true
            } label: {
                Image(systemName: DesignSystem.Icons.add)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Colors.primary)
            }
        }

        // 筛选菜单
        ToolbarItem(placement: .automatic) {
            Menu {
                // 优先级筛选
                Section("优先级") {
                    Picker("PRIORITY FILTER", selection: $selectedPriority) {
                        Text("全部").tag(nil as NotePriority?)

                        ForEach(NotePriority.allCases) { priority in
                            HStack {
                                Image(systemName: DesignSystem.Icons.priorityFlag)
                                    .foregroundStyle(Color.priority(priority))
                                Text(priority.localizedName)
                            }
                            .tag(priority as NotePriority?)
                        }
                    }
                }

                Divider()

                // 时间筛选
                Section("时间范围") {
                    Picker("TIME FILTER", selection: $selectedTimeFilter) {
                        ForEach(TimeFilter.allCases) { timeFilter in
                            HStack {
                                Image(systemName: DesignSystem.Icons.calendar)
                                    .foregroundStyle(DesignSystem.Colors.accent)
                                Text(timeFilter.rawValue)
                            }
                            .tag(timeFilter)
                        }
                    }
                }
            } label: {
                Image(systemName: DesignSystem.Icons.filter)
                    .symbolVariant(selectedPriority != nil || selectedTimeFilter != .all ? .fill : .none)
                    .foregroundStyle(
                        selectedPriority != nil || selectedTimeFilter != .all ?
                            DesignSystem.Colors.primary :
                            DesignSystem.Colors.textSecondary
                    )
            }
        }
    }

    // MARK: - Actions

    /// 切换完成状态
    private func toggleCompletion(for note: Note) {
        do {
            try repository.toggleCompleted(note)
        } catch {
            print("⚠️ Toggle completion failed: \(error)")
        }
    }

    /// 删除记事
    private func deleteNote(_ note: Note) {
        withAnimation(DesignSystem.Animation.standard) {
            do {
                try repository.delete(note)
            } catch {
                print("⚠️ Delete failed: \(error)")
            }
        }
    }

    /// 通过语音识别结果创建记事
    private func createNoteFromVoice(_ transcript: String) {
        do {
            let creator = VoiceNoteCreator(repository: repository)
            _ = try creator.createNote(from: transcript)
        } catch {
            voiceErrorMessage = error.localizedDescription
        }
    }
}

// MARK: - Previews

#Preview("Note List - With Data") {
    NoteListPreviewFactory.withData
}

#Preview("Note List - Empty") {
    NoteListPreviewFactory.empty
}

private enum NoteListPreviewFactory {
    static var withData: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: Note.self, ChecklistItem.self,
            configurations: config
        )

        // 添加示例数据
        let note1: Note = {
            let note = Note(
                title: "EVA UNIT-01 ACTIVATION",
                content: "Synchronization test required",
                priority: .high
            )

            note.items = [
                ChecklistItem(content: "Initialize pilot interface", isCompleted: true),
                ChecklistItem(content: "Run diagnostics", isCompleted: false),
                ChecklistItem(content: "Combat simulation", isCompleted: false)
            ]

            return note
        }()

        let note2 = Note(
            title: "NERV HEADQUARTERS BRIEFING",
            content: "Monthly status report",
            priority: .medium
        )

        let note3 = Note(
            title: "ANGEL ATTACK ANALYSIS",
            content: "Pattern blue detected",
            priority: .high,
            completed: true
        )

        [note1, note2, note3].forEach { container.mainContext.insert($0) }

        return NoteListView()
            .modelContainer(container)
    }

    static var empty: some View {
        NoteListView()
            .modelContainer(for: [Note.self, ChecklistItem.self], inMemory: true)
    }
}
