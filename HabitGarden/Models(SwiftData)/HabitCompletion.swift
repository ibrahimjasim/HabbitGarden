//
//  HabitCompletion.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-04-30.
//

import Foundation
import SwiftData

@Model
final class HabitCompletion {
    var date: Date
    var habit: Habit?

    init(date: Date = .now) {
        self.date = date
    }
}
