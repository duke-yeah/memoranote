//
//  NotePriority.swift
//  Memora
//
//  Created by Claude Code
//  Copyright © 2025 Memora. All rights reserved.
//

import Foundation

/// 记事优先级枚举
/// 定义了高、中、低三种优先级，用于帮助用户区分任务的重要程度
enum NotePriority: String, Codable, CaseIterable, Identifiable {
    case high
    case medium
    case low

    /// 符合 Identifiable 协议，用于 ForEach 等场景
    var id: String { rawValue }

    /// 优先级的显示名称（英文）
    var displayName: String {
        switch self {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        }
    }

    /// 优先级的显示名称（中文）
    var localizedName: String {
        switch self {
        case .high: return "高"
        case .medium: return "中"
        case .low: return "低"
        }
    }

    /// 优先级的简短显示名称（用于标签）
    var shortName: String {
        switch self {
        case .high: return "High"
        case .medium: return "Med"
        case .low: return "Low"
        }
    }

    /// 用于列表排序的权重值
    /// 数值越小优先级越高
    var sortWeight: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }

    /// 优先级的描述（用于 Picker 等组件）
    var description: String {
        localizedName
    }
}
