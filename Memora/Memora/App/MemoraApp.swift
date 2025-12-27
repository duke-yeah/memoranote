//
//  MemoraApp.swift
//  Memora
//
//  Created by Claude Code
//  Copyright © 2025 Memora. All rights reserved.
//

import SwiftUI
import SwiftData

/// Memora 应用主入口 - EVA 主题版本
/// 一款优雅的记事本应用，支持 iOS 和 macOS
/// EVA 主题：深色背景、初号机配色、科技感界面
@main
struct MemoraApp: App {
    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            NoteListView()
        }
        // 注册所有 SwiftData 模型：Note 和 ChecklistItem
        .modelContainer(for: [Note.self, ChecklistItem.self])
    }
}
