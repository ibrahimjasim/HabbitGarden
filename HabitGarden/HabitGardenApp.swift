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
    @State private var auth = AuthViewModel()

    init() {
        Task {
            await NotificationManager.requestNotificationPermission()
        }
    }

    var body: some Scene {
        WindowGroup {
            if auth.isLoggedIn {
                HabitListView()
            } else {
                LoginView(auth: auth)
            }
        }
        .environment(auth)
        .modelContainer(for: [Habit.self, HabitCompletion.self, AppAccount.self])
    }
}
