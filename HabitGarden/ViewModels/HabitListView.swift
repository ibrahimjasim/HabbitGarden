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
    
    func addHabit(name: String, emoji: String, context: ModelContext) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Name is required"
            return
        }
        let habit = Habit(name: trimmed, emoji: emoji)
        context.insert(habit)
        save(context: context)
    }
    
    func toggle(habit: Habit, context: ModelContext) {
        if StreakCalculater.isCopmletedToday(completions: habit.completions) {
            // Allow undo
            if let today = habit.completions.first(where: {
                Calendar.current.isDateInToday($0.date)
            }) {
                context.delete(today)
            }
        } else {
            let completion = HabitCompletion()
            completion.habit = habit
            context.insert(completion)
        }
        save(context: context)
    }
    
    func delete(habit: Habit, context: ModelContext) {
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
