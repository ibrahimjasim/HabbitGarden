//
//  Habit.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-04-30.
//

import Foundation
import SwiftData

@Model
final class Habit {
    var name: String
    var emoji: String
    var colorHex: String
    var createdAt: Date
    var reminderTime: Date?
    @Relationship(deleteRule: .cascade, inverse: \HabitCompletion.habit)
    var completions: [HabitCompletion] = []
    
    
    init(name: String, emoji: String = "🌱", colorHex: String = "#34C759") {
            self.name = name
            self.emoji = emoji
            self.colorHex = colorHex
            self.createdAt = .now
        }
}
