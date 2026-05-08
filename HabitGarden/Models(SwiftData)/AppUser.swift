//
//  AppUser.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-05-07.
//

import Foundation

// Lightweight user info stored in UserDefaults to keep the user logged in between app launches
// Codable so it can be saved/loaded as JSON
struct AppUser: Codable {
    let id: String       // Matches the AppAccount's UUID
    let name: String     // User's display name
    let email: String?   // User's email (optional for backwards compatibility)
}
