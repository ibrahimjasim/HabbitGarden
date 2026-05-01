//
//  HabitListView.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-05-01.
//

import SwiftUI
import SwiftData

struct HabitListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort:\Habit.createdAt) private var habits: [Habit]
    @State private var viewModel = HabitListViewModel()
    @State private var showAddSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(habits) { habit in
                    HabitRow(habit: habit){
                        viewModel.toggle(habit: habit, context: context)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewModel.delete(habit: habits[index], context: context)
                    }
                }
            }
        }
    }
    
    
}

