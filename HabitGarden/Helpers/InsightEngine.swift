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
        if let trendInsight = weeklyTrend(allCompletions) {
            insights.append(trendInsight)
        }
        if let topInsight = mostConsistentHabit(habits: habits) {
            insights.append(topInsight)
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
            colorName: "orange"
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
            colorName: "blue"
        )
    }

    private static func weeklyTrend(_ completions: [HabitCompletion]) -> SmartInsight? {
        let calendar = Calendar.current
        let now = Date()
        guard let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: now),
              let twoWeekAgo = calendar.date(byAdding: .day, value: -14, to: now) else { return nil }

        let thisWeek = completions.filter { $0.date >= oneWeekAgo }.count
        let lastWeek = completions.filter { $0.date >= twoWeekAgo && $0.date < oneWeekAgo }.count

        guard lastWeek >= 3 else { return nil } // need a baseline

        let change = (Double(thisWeek) - Double(lastWeek)) / Double(lastWeek) * 100
        guard abs(change) > 15 else { return nil } // Skip noise

        if change > 0 {
            return SmartInsight(
                title: "You're trending up",
                message: "You've completed \(Int(change))% more than last week. Keep going!",
                symbol: "chart.line.uptrend.xyaxis",
                colorName: "green"
            )
        } else {
            return SmartInsight(
                title: "Slight dip this week",
                message: "You're \(Int(abs(change)))% behind last week. Want to catch up?",
                symbol: "chart.line.downtrend.xyaxis",
                colorName: "red"
            )
        }
    }

    private static func mostConsistentHabit(habits: [Habit]) -> SmartInsight? {
        guard habits.count > 2 else { return nil }
        let calendar = Calendar.current

        let scored = habits.map { habit -> (Habit, Double) in
            let days: [Date] = (0..<7).map {
                calendar.startOfDay(for: calendar.date(byAdding: .day, value: -$0, to: .now)!)
            }
            let completedDays = Set(habit.completions.map { calendar.startOfDay(for: $0.date) })
            let hits = days.filter { completedDays.contains($0) }.count
            return (habit, Double(hits) / 7.0)
        }

        guard let top = scored.max(by: { $0.1 < $1.1 }), top.1 > 0.5 else { return nil }

        return SmartInsight(
            title: "Your strongest habit",
            message: "\(top.0.emoji) \(top.0.name) - \(Int(top.1 * 100))% this week",
            symbol: "star.fill",
            colorName: "yellow"
        )
    }
}
