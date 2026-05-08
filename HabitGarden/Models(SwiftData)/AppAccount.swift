//
//  AppAccount.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-05-08.
//

import Foundation
import SwiftData

@Model
final class AppAccount {
    var id = UUID()
    @Attribute(.unique) var email: String
    var name : String
    var passwordHash: String
    var createdAt: Date
    
    init(email: String, name: String, passwordHash :String){
        self.email = email
        self.name = name
        self.passwordHash = passwordHash
        self.createdAt = .now
    }
}
