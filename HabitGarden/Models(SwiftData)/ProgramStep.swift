//
//  ProgramStep.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-06-09.
//

import Foundation
import SwiftData

@Model
final class ProgramStep {
    @Attribute(.unique) var id = UUID()
    var title: String
    var order: Int               // controls the display sequence (step 1, 2, 3...)
    var completedAt: Date?       // nil = not done, set = done (and when)
    var program: Program?        // back-reference SwiftData needs for the relationship

    init(title: String, order: Int) {
        self.title = title
        self.order = order
        self.completedAt = nil
    }

    // Computed helper — true if this step has been completed today
    var isCompletedToday: Bool {
        guard let date = completedAt else { return false }
        return Calendar.current.isDateInToday(date)
    }
}
