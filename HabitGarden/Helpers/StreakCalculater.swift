//
//  StreakCalculator.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-04-30.
//

import Foundation

// Calculates streaks and daily completion status for habits
struct StreakCalculator {

    // Returns how many consecutive days the habit was completed (e.g. "5 day streak")
    static func currentStreak(for habit: Habit) -> Int {
        let calendar = Calendar.current

        // Group completions by day
        let perDay = Dictionary(grouping: habit.completions) {
            calendar.startOfDay(for: $0.date)
        }

        // Only count days where the user hit their target (e.g. 3/3 times)
        let completedDays = Set(perDay.filter { $0.value.count >= habit.targetPerDay }.keys)

        var day = calendar.startOfDay(for: .now)

        // If the user hasn't completed today yet, don't break their streak —
        // start counting from yesterday instead
        if !completedDays.contains(day) {
            day = calendar.date(byAdding: .day, value: -1, to: day)!
        }

        // Walk backwards day by day until we find a gap
        var streak = 0
        while completedDays.contains(day) {
            streak += 1
            day = calendar.date(byAdding: .day, value: -1, to: day)!
        }

        return streak
    }

    // Returns how many times the habit was completed today (e.g. 2 out of 3)
    static func isCompletedToday(_ completions: [HabitCompletion]) -> Int {
        let today = Calendar.current.startOfDay(for: .now)
        return completions.filter {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }.count
    }

    // Returns true if the habit has fully met its daily target today
    static func isCompletedToday(_ habit: Habit) -> Bool {
        isCompletedToday(habit.completions) >= habit.targetPerDay
    }
}


