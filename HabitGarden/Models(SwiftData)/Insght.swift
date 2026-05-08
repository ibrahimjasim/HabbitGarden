//
//  Insght.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-05-05.
//

import Foundation
import SwiftUI


// Represents one insight card shown on the Insights screen (e.g. "You're a Morning person")
struct SmartInsight: Identifiable, Codable {
    var id = UUID()
    let title: String       // Bold headline text
    let message: String     // Descriptive detail text
    let symbol: String      // SF Symbol name or emoji shown as the icon
    let colorName: String   // Color name stored as a string (so it can be Codable)

    // Converts the colorName string into an actual SwiftUI Color
    var color: Color {
        switch colorName {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        default: return .primary
        }
    }
}
