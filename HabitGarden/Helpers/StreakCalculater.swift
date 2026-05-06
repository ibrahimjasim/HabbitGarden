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
    static func currentStreak(for habit: Habit) -> Int {
        let calendar = Calendar.current

        let perDay = Dictionary(grouping: habit.completions) {
            calendar.startOfDay(for: $0.date)
        }

        let completedDays = Set(perDay.filter { $0.value.count >= habit.targetPerDay }.keys)
        
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

    /// Number of completions today (handles multi-completion habits).
    static func isCompletedToday(_ completions: [HabitCompletion]) -> Int {
        let today = Calendar.current.startOfDay(for: .now)
        return completions.filter {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }.count
    }
    /// True if the habit has met its daily target.
    static func isCompletedToday(_ habit: Habit) -> Bool {
        isCompletedToday(habit.completions) >= habit.targetPerDay
    }
}


