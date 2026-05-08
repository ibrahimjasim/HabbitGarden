//
//  HabitGardenApp.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-04-30.
//

import SwiftUI
import SwiftData

// The entry point of the app — this is where everything starts
@main
struct HabitGardenApp: App {

    // Holds the current user's login state (shared across all views)
    @State private var auth = AuthViewModel()

    init() {
        // Ask the user for permission to send daily reminders
        Task {
            await NotificationManager.requestNotificationPermission()
        }
    }

    var body: some Scene {
        WindowGroup {
            // Auth gate: show the main screen if logged in, otherwise show login
            if auth.isLoggedIn {
                HabitListView()
            } else {
                LoginView(auth: auth)
            }
        }
        // Make the auth view-model available to every view in the app
        .environment(auth)
        // Set up the local database with all the models the app uses
        .modelContainer(for: [Habit.self, HabitCompletion.self, AppAccount.self])
    }
}
