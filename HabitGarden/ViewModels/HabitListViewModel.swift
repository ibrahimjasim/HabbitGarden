//
//  HabitListView.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-05-01.
//

import Foundation
import SwiftData

// Handles all habit-related actions: adding, toggling completion, and deleting
@MainActor
@Observable
final class HabitListViewModel{
    var errorMessage: String?   // Shown in an alert if something fails

    // Creates a new habit and saves it to the database
    func addHabit(name: String, emoji: String, targetPerDay: Int = 1, reminderTime: Date? = nil, userId: String, context: ModelContext) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Name is required"
            return
        }
        // Create the habit and link it to the current user
        let habit = Habit(name: trimmed, emoji: emoji, targetPerDay: targetPerDay, userId: userId)
        habit.reminderTime = reminderTime
        context.insert(habit)
        save(context: context)

        // If the user enabled reminders, schedule a daily notification
        if let reminderTime {
            NotificationManager.schedule(
                habitId: habit.id.uuidString,
                name: habit.name,
                emoji: habit.emoji,
                time: reminderTime
            )
        }
      }

    // Marks a habit as done (or undoes it if already completed today)
    func toggle(habit: Habit, context: ModelContext) {
        let todayCount = StreakCalculator.isCompletedToday(habit.completions)
        if todayCount >= habit.targetPerDay {
            // Already completed today — remove the most recent completion (undo)
            if let last = habit.completions
                .filter({ Calendar.current.isDateInToday($0.date) })
                .sorted(by: { $0.date > $1.date })
                .first {
                context.delete(last)
            }
        } else {
            // Not yet completed — add a new completion record
            let completion = HabitCompletion()
            completion.habit = habit
            context.insert(completion)
        }
        save(context: context)
    }

    // Deletes a habit and cancels its notification
    func delete(habit: Habit, context: ModelContext) {
        NotificationManager.cancel(habitId: habit.id.uuidString)
        context.delete(habit)
        save(context: context)
    }

    // Saves changes to the database, sets errorMessage if it fails
    private func save(context: ModelContext) {
        do {
            try context.save()
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
        }
    }
}
