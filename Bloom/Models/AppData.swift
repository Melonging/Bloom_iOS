import Foundation
import SwiftUI
import Combine

@MainActor
final class AppData: ObservableObject {
    @Published var mappings: [Mapping] {
        didSet { persistMappings() }
    }
    @Published var logs: [String: [Int]] {
        didSet { persistLogs() }
    }
    @Published var onboarded: Bool {
        didSet { UserDefaults.standard.set(onboarded, forKey: Keys.onboarded) }
    }

    enum Keys {
        static let mappings = "bloom_map"
        static let logs = "bloom_logs"
        static let onboarded = "bloom_onboarded"
    }

    init() {
        let d = UserDefaults.standard
        if let data = d.data(forKey: Keys.mappings),
           let decoded = try? JSONDecoder().decode([Mapping].self, from: data) {
            self.mappings = AppData.migrateIcons(decoded)
        } else {
            self.mappings = Mapping.defaults
        }
        if let data = d.data(forKey: Keys.logs),
           let decoded = try? JSONDecoder().decode([String: [Int]].self, from: data) {
            self.logs = decoded
        } else {
            self.logs = [:]
        }
        self.onboarded = d.bool(forKey: Keys.onboarded)

        if self.logs.isEmpty {
            self.logs = AppData.seedLogs(mappings: self.mappings)
        }
    }

    /// Replace any legacy emoji icons with SF Symbol names so they render correctly.
    private static func migrateIcons(_ mappings: [Mapping]) -> [Mapping] {
        let emojiToSymbol: [String: String] = [
            "🏃": "figure.run",
            "💧": "drop.fill",
            "📚": "book.fill",
            "🧘": "figure.mind.and.body",
            "💊": "pills.fill",
            "🌿": "leaf.fill",
            "✏️": "pencil",
            "🎵": "music.note",
            "🍎": "fork.knife",
            "😴": "moon.zzz.fill",
            "🧹": "sparkles",
            "💪": "dumbbell.fill",
            "🧴": "face.smiling",
            "🚶": "figure.walk",
            "☕": "cup.and.saucer.fill",
        ]
        return mappings.map { m in
            var copy = m
            if let mapped = emojiToSymbol[m.icon] {
                copy.icon = mapped
            } else if !BLOOM_ICONS.contains(m.icon) {
                // unknown icon (could be emoji not in the map, or empty): fall back to default for this id
                if let def = Mapping.defaults.first(where: { $0.id == m.id }) {
                    copy.icon = def.icon
                }
            }
            return copy
        }
    }

    private func persistMappings() {
        if let data = try? JSONEncoder().encode(mappings) {
            UserDefaults.standard.set(data, forKey: Keys.mappings)
        }
    }
    private func persistLogs() {
        if let data = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(data, forKey: Keys.logs)
        }
    }

    // MARK: - Helpers

    static func dateKey(_ d: Date) -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.timeZone = TimeZone.current
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: d)
    }

    var todayKey: String { Self.dateKey(Date()) }
    var todaySet: Set<Int> { Set(logs[todayKey] ?? []) }

    var mapped: [Mapping] { mappings.filter { !$0.name.isEmpty } }

    func isDone(_ id: Int) -> Bool { todaySet.contains(id) }

    func toggle(_ id: Int) {
        var set = todaySet
        if set.contains(id) { set.remove(id) } else { set.insert(id) }
        logs[todayKey] = Array(set)
    }

    func update(mapping: Mapping) {
        if let idx = mappings.firstIndex(where: { $0.id == mapping.id }) {
            mappings[idx] = mapping
        }
    }

    func resetToday() {
        let k = todayKey
        if logs[k] == nil { logs[k] = [] }
    }

    /// Streak count: how many consecutive past days had all mapped todos completed.
    /// Today is skipped if not yet completed (matches HTML behaviour).
    func streakCount() -> Int {
        let mp = mapped
        guard !mp.isEmpty else { return 0 }
        let cal = Calendar(identifier: .gregorian)
        var streak = 0
        let now = Date()
        for i in 0...60 {
            guard let d = cal.date(byAdding: .day, value: -i, to: now) else { break }
            let k = Self.dateKey(d)
            let doneCount = (logs[k] ?? []).count
            if i == 0 && doneCount == 0 && k == todayKey { continue }
            if doneCount >= mp.count {
                streak += 1
            } else if i > 0 {
                break
            }
        }
        return streak
    }

    // MARK: - Week data

    struct WeekDay: Identifiable {
        let id: String
        let date: Date
        let key: String
        let done: Int
        let total: Int
        let pct: Double  // 0...1
        let isFuture: Bool
        let day: String
    }

    struct WeekData {
        let weekDays: [WeekDay]
        let totalDone: Int
        let pct: Int       // 0...100
        let perfectDays: Int
        let monday: Date
        let mapped: [Mapping]
    }

    func weekData() -> WeekData {
        let cal = Calendar(identifier: .gregorian)
        let now = Date()
        let dow = cal.component(.weekday, from: now) // 1=Sun ... 7=Sat
        // shift so Monday is start
        let shift = dow == 1 ? 6 : dow - 2
        let monday = cal.startOfDay(for: cal.date(byAdding: .day, value: -shift, to: now)!)
        let mp = mapped
        var days: [WeekDay] = []
        for i in 0..<7 {
            let d = cal.date(byAdding: .day, value: i, to: monday)!
            let k = Self.dateKey(d)
            let done = (logs[k] ?? []).count
            let isFuture = d > now
            let pct = mp.isEmpty ? 0 : Double(done) / Double(mp.count)
            let weekday = cal.component(.weekday, from: d) - 1 // 0..6, sun-based
            days.append(WeekDay(
                id: k, date: d, key: k, done: done, total: mp.count,
                pct: pct, isFuture: isFuture, day: WEEK_DAYS_KO[weekday]
            ))
        }
        let active = days.filter { !$0.isFuture }
        let totalDone = active.reduce(0) { $0 + $1.done }
        let totalPossible = active.reduce(0) { $0 + $1.total }
        let pct = totalPossible > 0 ? Int(round(Double(totalDone) / Double(totalPossible) * 100)) : 0
        let perfect = active.filter { $0.pct >= 1 }.count
        return WeekData(weekDays: days, totalDone: totalDone, pct: pct,
                        perfectDays: perfect, monday: monday, mapped: mp)
    }

    /// Routine completion counts across all logs.
    func routineCounts() -> [Int: Int] {
        var counts: [Int: Int] = [:]
        mapped.forEach { counts[$0.id] = 0 }
        for done in logs.values {
            for id in done where counts[id] != nil {
                counts[id, default: 0] += 1
            }
        }
        return counts
    }

    /// Routine counts limited to a given set of date keys.
    func routineCounts(in keys: Set<String>) -> [Int: Int] {
        var counts: [Int: Int] = [:]
        mapped.forEach { counts[$0.id] = 0 }
        for (k, done) in logs where keys.contains(k) {
            for id in done where counts[id] != nil {
                counts[id, default: 0] += 1
            }
        }
        return counts
    }

    // MARK: - Seed

    static func seedLogs(mappings: [Mapping]) -> [String: [Int]] {
        let cal = Calendar(identifier: .gregorian)
        let active = mappings.filter { !$0.name.isEmpty }.map { $0.id }
        guard !active.isEmpty else { return [:] }
        var out: [String: [Int]] = [:]
        let now = Date()
        for i in 1...30 {
            guard let d = cal.date(byAdding: .day, value: -i, to: now) else { continue }
            let k = dateKey(d)
            let maxN = active.count
            let n = max(1, Int.random(in: 1...maxN))
            let shuffled = active.shuffled()
            out[k] = Array(shuffled.prefix(n))
        }
        return out
    }
}
