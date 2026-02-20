import Foundation

@MainActor
final class VoiceNoteCreator {
    private let parser = NLPParser()
    private let repository: NoteRepository

    init(repository: NoteRepository) {
        self.repository = repository
    }

    @discardableResult
    func createNote(from voiceText: String) throws -> Note {
        let text = voiceText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            throw VoiceNoteError.emptyTranscript
        }

        let parsed = parser.parse(text)
        let title = buildTitle(from: text, keywords: parsed.detectedKeywords)

        let note = Note(
            title: title.isEmpty ? "VOICE NOTE" : title,
            content: text,
            priority: parsed.priority,
            dueDate: parsed.dueDate
        )

        if !parsed.checklistItems.isEmpty {
            note.items = parsed.checklistItems.map { ChecklistItem(content: $0) }
        }

        return try repository.create(note: note)
    }

    private func buildTitle(from text: String, keywords: [String]) -> String {
        var title = text
        for keyword in keywords where !keyword.isEmpty {
            title = title.replacingOccurrences(of: keyword, with: "")
        }
        title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if title.count > 40 {
            let index = title.index(title.startIndex, offsetBy: 40)
            title = String(title[..<index])
        }
        return title
    }
}

struct NLPParser {
    struct ParsedResult {
        var dueDate: Date?
        var priority: NotePriority = .medium
        var checklistItems: [String] = []
        var detectedKeywords: [String] = []
    }

    func parse(_ text: String) -> ParsedResult {
        var result = ParsedResult()

        result.dueDate = parseDate(from: text)
        result.priority = parsePriority(from: text)
        result.checklistItems = parseChecklist(from: text)
        result.detectedKeywords = extractKeywords(from: text)

        return result
    }

    private func parseDate(from text: String) -> Date? {
        let calendar = Calendar.current
        let now = Date()

        if text.contains("后天") {
            return buildDate(dayOffset: 2, text: text, calendar: calendar, now: now)
        }
        if text.contains("明天") || text.lowercased().contains("tomorrow") {
            return buildDate(dayOffset: 1, text: text, calendar: calendar, now: now)
        }
        if text.contains("下周") {
            return calendar.date(byAdding: .day, value: 7, to: now)
        }
        if let days = extractNumber(from: text, pattern: "(\\d+)天后") {
            return calendar.date(byAdding: .day, value: days, to: now)
        }

        return nil
    }

    private func buildDate(dayOffset: Int, text: String, calendar: Calendar, now: Date) -> Date? {
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.day = (components.day ?? 0) + dayOffset

        if text.contains("下午") || text.contains("晚上") {
            let hour = (extractNumber(from: text, pattern: "(\\d+)点") ?? 7) + 12
            components.hour = min(hour, 23)
            components.minute = 0
        } else if text.contains("上午") || text.contains("早上") || text.contains("点") {
            components.hour = extractNumber(from: text, pattern: "(\\d+)点") ?? 9
            components.minute = 0
        }

        return calendar.date(from: components)
    }

    private func parsePriority(from text: String) -> NotePriority {
        let lowercased = text.lowercased()
        let highKeywords = ["紧急", "重要", "高优先级", "马上", "立即", "urgent", "asap"]
        let lowKeywords = ["不急", "有空", "低优先级", "以后", "later", "low priority"]

        if highKeywords.contains(where: { text.contains($0) || lowercased.contains($0) }) {
            return .high
        }
        if lowKeywords.contains(where: { text.contains($0) || lowercased.contains($0) }) {
            return .low
        }
        return .medium
    }

    private func parseChecklist(from text: String) -> [String] {
        let patterns = [
            "第[一二三四五六七八九十].*?(?=第[一二三四五六七八九十]|$)",
            "\\d+[.、].*?(?=\\d+[.、]|$)"
        ]

        var items: [String] = []

        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern) else { continue }
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            for match in matches {
                guard let range = Range(match.range, in: text) else { continue }
                let item = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                if !item.isEmpty {
                    items.append(item)
                }
            }
            if !items.isEmpty {
                return items
            }
        }

        return items
    }

    private func extractKeywords(from text: String) -> [String] {
        let keywords = [
            "明天", "后天", "下周", "下午", "上午", "晚上",
            "紧急", "重要", "高优先级", "低优先级", "马上", "立即",
            "tomorrow", "urgent", "asap"
        ]
        return keywords.filter { text.localizedCaseInsensitiveContains($0) }
    }

    private func extractNumber(from text: String, pattern: String) -> Int? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        guard
            let firstMatch = matches.first,
            let range = Range(firstMatch.range(at: 1), in: text)
        else {
            return nil
        }
        return Int(text[range])
    }
}

enum VoiceNoteError: LocalizedError {
    case emptyTranscript

    var errorDescription: String? {
        switch self {
        case .emptyTranscript:
            return "No voice transcript captured."
        }
    }
}
