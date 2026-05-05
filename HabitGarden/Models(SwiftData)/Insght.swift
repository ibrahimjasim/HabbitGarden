//
//  Insght.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-05-05.
//

import Foundation
import SwiftUI


struct SmartInsight: Identifiable, Codable {
    var id = UUID()
    let title: String
    let message: String
    let symbol: String
    let colorName: String

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
