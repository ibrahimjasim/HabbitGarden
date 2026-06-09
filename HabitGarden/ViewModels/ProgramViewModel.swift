//
//  ProgramViewModel.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-06-09.
//

import Foundation
import SwiftData

@Observable
final class ProgramViewModel {
    var errorMessage: String? = nil
    
    // Create a new program and save it in the database
    func addProgram(name: String, emoji: String, isRepeating: Bool, userID: String, context: ModelContext) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Program name cannot be empty"
            return
        }
        let program = Program(name: name, emoji: emoji, isRepeating: isRepeating, userId: userID)
        context.insert(program)
        save(context)
    }
    
    // Add a step to an existing program
    func addStep(title: String, to program: Program, context: ModelContext) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {return}
        let order = program.steps.count // Next index becomes the order number
        let step = ProgramStep(title: title, order: order)
        step.program = program
        program.steps.append(step)
        save(context)
    }
    
    // Toggle a step done/undone for today
    func toggleStep(_ step:ProgramStep, context: ModelContext){
        if step.isCompletedToday {
            step.completedAt = nil // undo
        } else {
            step.completedAt = .now // mark done
        }
        save(context)
    }
    
    // Reset all steps in repeating program (called at start of new day)
    func resetIfNeeded(for program: Program, context: ModelContext) {
        guard program.isRepeating else {return}
        for step in program.steps {
            if let date = step.completedAt, Calendar.current.isDateInToday(date) {
                step.completedAt = nil
            }
        }
        save(context)
    }
    
    // Delete a program
    func delete(_ program: Program, context: ModelContext) {
        context.delete(program)
        save(context)
    }
    
    private func save(_ context: ModelContext) {
        do {
            try context.save()
        } catch {
            errorMessage = "Faild to save : \(error.localizedDescription)"
        }
    }
}
