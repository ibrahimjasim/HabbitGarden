//
//  Habit.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-04-30.
//

import Foundation
import SwiftData

// The main data model — each Habit is one thing the user wants to track daily
@Model
final class Habit {
    @Attribute(.unique) var id = UUID()     // Unique identifier
    var userId: String?                     // Which user owns this habit (links to AppAccount)
    var name: String                        // e.g. "Morning walk"
    var emoji: String                       // Visual symbol shown in the UI
    var colorHex: String                    // Hex color for theming
    var createdAt: Date                     // When the habit was created
    var reminderTime: Date?                 // If set, the app sends a daily notification at this time
    var goalDays: Int?
    var targetPerDay: Int = 1

    // When a habit is deleted, all its completions are automatically deleted too
    @Relationship(deleteRule: .cascade, inverse: \HabitCompletion.habit)
    var completions: [HabitCompletion] = []


    init(name: String, emoji: String = "🌱", colorHex: String = "#34C759", targetPerDay: Int = 1, goalDays: Int? = nil, userId: String? = nil) {
            self.name = name
            self.emoji = emoji
            self.colorHex = colorHex
            self.createdAt = .now
            self.targetPerDay = targetPerDay
            self.goalDays = goalDays
            self.userId = userId
        }
}
