//
//  StreakCalculator.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-04-30.
//

import Foundation

struct StreakCalculator {

    /// Returns the number of consecutive days the habit was completed,
    /// counting backwards from today.
    static func currentStreak(completions: [HabitCompletion]) -> Int {
        let calendar = Calendar.current

        // Convert each completion date to "start of day" so we ignore the time.
        // Using a Set makes the lookup below O(1) instead of O(n).
        let completedDays = Set(completions.map {
            calendar.startOfDay(for: $0.date)
        })

        var streak = 0
        var day = calendar.startOfDay(for: .now)

        // Edge case: if the user hasn't checked off today yet, don't reset
        // their streak — start counting from yesterday.
        if !completedDays.contains(day) {
            day = calendar.date(byAdding: .day, value: -1, to: day)!
        }

        // Walk backwards day by day. Stop on the first missing day.
        while completedDays.contains(day) {
            streak += 1
            day = calendar.date(byAdding: .day, value: -1, to: day)!
        }

        return streak
    }

    /// Returns true if the habit has at least one completion today.
    static func isCompletedToday(completions: [HabitCompletion]) -> Bool {
        let today = Calendar.current.startOfDay(for: .now)
        return completions.contains {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }
    }
}
