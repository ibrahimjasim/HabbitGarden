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
    let color: Color
}
