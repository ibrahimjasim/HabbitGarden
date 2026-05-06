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
    @Query(sort: \Habit.createdAt) private var habits: [Habit]
    @State private var viewModel = HabitListViewModel()
    @State private var showAddSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if habits.isEmpty {
                    ContentUnavailableView(
                        "No habits yet",
                        systemImage: "leaf",
                        description: Text("Tap + to add your first habit.")
                    )
                } else {
                    List {
                        ForEach(habits) { habit in
                            NavigationLink(destination: HabitDetailView(habit: habit)) {
                                HabitRow(habit: habit) {
                                    viewModel.toggle(habit: habit, context: context)
                                }
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
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        
                        InsightsView()
                    } label: {
                        Image(systemName: "chart.bar.fill")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        GardenView()
                    } label: {
                        Image(systemName: "leaf.fill")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddHabitView(viewModel: viewModel)
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
}

struct HabitRow: View {
    let habit: Habit
    let onToggle: () -> Void

    var body: some View {
        HStack {
            if habit.emoji.isEmpty {
                Image(systemName: "circle.dashed")
                    .font(.title)
                    .foregroundStyle(.secondary)
            } else {
                Text(habit.emoji).font(.title)
            }
            VStack(alignment: .leading) {
                Text(habit.name).font(.headline)
                Text("🔥 \(StreakCalculator.currentStreak(for: habit)) day streak")
                if habit.targetPerDay > 1 {
                    Text("\(StreakCalculator.isCompletedToday(habit.completions))/\(habit.targetPerDay)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button {
                onToggle()
            } label: {
                Image(systemName: StreakCalculator.isCompletedToday(habit)
                    ? "checkmark.circle.fill"
                    : (habit.targetPerDay > 1 ? "plus.circle.fill" : "circle"))
                    .font(.title)
                    .foregroundStyle(.green)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    HabitListView()
        .modelContainer(for: [Habit.self, HabitCompletion.self], inMemory: true)
}
