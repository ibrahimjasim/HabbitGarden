//
//  InsightEngine.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-05-05.
//

import Foundation
import SwiftUI

struct InsightEngine {
    
    
    static func generate(habits: [Habit]) -> [SmartInsight] {
        let allCompletions = habits.flatMap { $0.completions }
        guard allCompletions.count > 5 else { return [] }
    }
}
