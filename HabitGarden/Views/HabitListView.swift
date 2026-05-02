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
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .alert(
                "Something went wrong",
                isPresented: .constant(viewModel.errorMessage != nil)
            ) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    struct HabitRow: View {
        let habit: Habit
        let onToggle: () -> Void

        var body: some View {
            HStack {
                Text(habit.emoji).font(.title)
                VStack(alignment: .leading) {
                    Text(habit.name).font(.headline)
                    Text("🔥 \(StreakCalculater.currentStreak(completions: habit.completions)) day streak")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    onToggle()
                } label: {
                    Image(systemName: StreakCalculater.isCopmletedToday(completions: habit.completions)
                        ? "checkmark.circle.fill" : "circle")
                        .font(.title)
                        .foregroundStyle(.green)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    
}

