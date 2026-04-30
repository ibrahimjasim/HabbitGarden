//
//  HabitGardenApp.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-04-30.
//

import SwiftUI
import SwiftData

@main
struct HabitGardenApp: App {
    var body: some Scene {
        WindowGroup {
            HabitListView()
        }
        .modelContainer(for: [Habit.self, HabitCompletion.self])
    }
}
