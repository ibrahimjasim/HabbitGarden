//
//  HabitListView.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-05-01.
//

import Foundation
import SwiftData

@MainActor
@Observable
final class HabitListViewModel{
    var errorMessage: String?
    
    func addHabit(name: String, emoji: String, targetPerDay: Int = 1, reminderTime: Date? = nil, userId: String, context: ModelContext) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Name is required"
            return
        }
        let habit = Habit(name: trimmed, emoji: emoji, targetPerDay: targetPerDay, userId: userId)
        habit.reminderTime = reminderTime
        context.insert(habit)
        save(context: context)
        
        if let reminderTime {
            NotificationManager.schedule(
                habitId: habit.id.uuidString,
                name: habit.name,
                emoji: habit.emoji,
                time: reminderTime
            )
        }
      }

    func toggle(habit: Habit, context: ModelContext) {
        let todayCount = StreakCalculator.isCompletedToday(habit.completions)
        if todayCount >= habit.targetPerDay {
            if let last = habit.completions
                .filter({ Calendar.current.isDateInToday($0.date) })
                .sorted(by: { $0.date > $1.date })
                .first {
                context.delete(last)
            }
        } else {
            let completion = HabitCompletion()
            completion.habit = habit
            context.insert(completion)
        }
        save(context: context)
    }
    
    func delete(habit: Habit, context: ModelContext) {
        NotificationManager.cancel(habitId: habit.id.uuidString)
        context.delete(habit)
        save(context: context)
    }
    private func save(context: ModelContext) {
        do {
            try context.save()
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
        }
    }
}
