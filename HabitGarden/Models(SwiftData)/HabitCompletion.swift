//
//  HabitCompletion.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-04-30.
//

import Foundation
import SwiftData

// Records a single completion — every time the user taps the checkmark, one of these is created
@Model
final class HabitCompletion {
    var date: Date       // When the habit was completed
    var habit: Habit?    

    init(date: Date = .now) {
        self.date = date
    }
}
