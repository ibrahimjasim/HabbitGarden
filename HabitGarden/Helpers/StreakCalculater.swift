//
//  StreakCalculater.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-04-30.
//

import Foundation

struct StreakCalculater {
    static func currentStreak(completions : [HabitCompletion]) -> Int {
        let calendar = Calendar.current
        let completedDays  = Set(completions.map{
            
            calendar.startOfDay(for: $0.date)
        })
        
        var streak = 0
        var day = calendar.startOfDay(for: .now)
        
        // If today not done yet, start from yesterday so streak doesn't reset at midnight
       if !completedDays.contains(day) {
            day = calendar.date(byAdding: .day, value: -1, to: day)!
        }
        
        while completedDays.contains(day) {
            streak += 1
            day = calendar.date(byAdding: .day, value: -1, to: day)!
        }
        
        return streak
    }
    
    static func isCopmletedToday(completions: [HabitCompletion]) -> Bool {
        let today = Calendar.current.startOfDay(for: .now)
        return completions.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: today) })
    }
}
