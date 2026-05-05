//
//  InsightEngine.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-05-05.
//

import Foundation
import SwiftUI

struct InsightEngine {

    /// Returns up to 4 insights worth showing right now.
    /// Filters out insights with too little data so they don't look silly.
    static func generate(habits: [Habit]) -> [SmartInsight] {
        let allCompletions = habits.flatMap { $0.completions }
        guard allCompletions.count > 5 else { return [] }

        var insights: [SmartInsight] = []

        if let timeInsight = bestTimeOfDay(completions: allCompletions) {
            insights.append(timeInsight)
        }
        if let dayInsight = bestDayOfWeek(completions: allCompletions) {
            insights.append(dayInsight)
        }

        return insights
    }

    // MARK: - Individual insights

    // Returns the bucket with the most.
    private static func bestTimeOfDay(completions: [HabitCompletion]) -> SmartInsight? {
        let buckets: [String: [HabitCompletion]] = Dictionary(grouping: completions) { c in
            let hour = Calendar.current.component(.hour, from: c.date)
            switch hour {
            case 5..<12: return "Morning"
            case 12..<17: return "Afternoon"
            case 17..<21: return "Evening"
            default: return "Night"
            }
        }

        guard let best = buckets.max(by: { $0.value.count < $1.value.count }) else { return nil }

        let total = completions.count
        let percent = best.value.count * 100 / total
        guard percent >= 35 else { return nil } // skip if it's not actually a pattern

        let symbol: String
        switch best.key {
        case "Morning": symbol = "☀️"
        case "Afternoon": symbol = "🌤️"
        case "Evening": symbol = "🌆"
        default: symbol = "🌙"
        }

        return SmartInsight(
            title: "You're a \(best.key) person",
            message: "\(percent)% of your habits get done in the \(best.key).",
            symbol: symbol,
            color: .orange
        )
    }

    /// Finds your most productive day of the week.
    private static func bestDayOfWeek(completions: [HabitCompletion]) -> SmartInsight? {
        let calendar = Calendar.current
        let buckets = Dictionary(grouping: completions) {
            calendar.component(.weekday, from: $0.date)
        }

        guard let best = buckets.max(by: { $0.value.count < $1.value.count }) else { return nil }
        guard best.value.count > 3 else { return nil }

        // weekday: 1 = Sunday, 2 = Monday, etc
        let dayName = calendar.weekdaySymbols[best.key - 1]

        return SmartInsight(
            title: "\(dayName)s are your strongest day",
            message: "You've completed \(best.value.count) habits on \(dayName)s.",
            symbol: "calendar",
            color: .blue
        )
    }
}
