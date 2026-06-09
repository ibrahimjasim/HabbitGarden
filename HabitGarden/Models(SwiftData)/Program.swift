//
//  Program.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-06-09.
//

import Foundation
import SwiftData

@Model
final class Program {
    @Attribute(.unique) var id = UUID()
    var userId: String?
    var name: String
    var emoji: String
    var createdAt: Date
    var isRepeating: Bool        // true = resets daily, false = one-time checklist

    @Relationship(deleteRule: .cascade, inverse: \ProgramStep.program)
    var steps: [ProgramStep] = []

    init(name: String, emoji: String = "📋", isRepeating: Bool = true, userId: String? = nil) {
        self.name = name
        self.emoji = emoji
        self.createdAt = .now
        self.isRepeating = isRepeating
        self.userId = userId
    }
}
