//
//  AppAccount.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-05-08.
//

import Foundation
import SwiftData

// Stored in the local database — represents a registered user account
@Model
final class AppAccount {
    var id = UUID()                          // Unique identifier for this account
    @Attribute(.unique) var email: String    // Email must be unique (no duplicate accounts)
    var name : String                        // Display name
    var passwordHash: String                 // SHA-256 hash of the password (never store plain text)
    var createdAt: Date                      // When the account was created

    init(email: String, name: String, passwordHash :String){
        self.email = email
        self.name = name
        self.passwordHash = passwordHash
        self.createdAt = .now
    }
}
