//
//  HabitListView.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-05-01.
//

import SwiftUI
import SwiftData

// The main screen — shows the list of habits for the logged-in user
struct HabitListView: View {
    @Environment(\.modelContext) private var context          // Database access
    @Environment(AuthViewModel.self) private var auth         // Current user info
    @Query(sort: \Habit.createdAt) private var habits: [Habit] // All habits from the database
    @State private var viewModel = HabitListViewModel()
    @State private var showAddSheet = false

    // Filter to only show habits that belong to the current user
    private var userHabits: [Habit] {
        guard let userId = auth.currentUser?.id else { return [] }
        return habits.filter { $0.userId == userId }
    }

    var body: some View {
        NavigationStack {
            Group {
                // Show a placeholder if the user has no habits yet
                if userHabits.isEmpty {
                    ContentUnavailableView(
                        "No habits yet",
                        systemImage: "leaf",
                        description: Text("Tap + to add your first habit.")
                    )
                } else {
                    // List of habits — tap to edit, swipe to delete
                    List {
                        ForEach(userHabits) { habit in
                            NavigationLink(destination: HabitDetailView(habit: habit)) {
                                HabitRow(habit: habit) {
                                    viewModel.toggle(habit: habit, context: context)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.delete(habit: userHabits[index], context: context)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Habits")
            .toolbar {
                // Navigate to the Insights screen (charts and stats)
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {

                        InsightsView()
                    } label: {
                        Image(systemName: "chart.bar.fill")
                    }
                }
                // Navigate to the Garden view (visual plant representation)
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        GardenView()
                    } label: {
                        Image(systemName: "leaf.fill")
                    }
                }
                // Sign out button
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        auth.signOut()
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                }
                // Add new habit button
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
            // Error alert for save failures
            .alert(
                "Something went wrong",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                )
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

// A single row in the habit list — shows emoji, name, streak, and a toggle button
struct HabitRow: View {
    let habit: Habit
    let onToggle: () -> Void

    var body: some View {
        HStack {
            // Show the habit's emoji or a placeholder if none is set
            if habit.emoji.isEmpty {
                Image(systemName: "circle.dashed")
                    .font(.title)
                    .foregroundStyle(.secondary)
            } else {
                Text(habit.emoji).font(.title)
            }
            VStack(alignment: .leading) {
                HStack(spacing: 6) {

                Text(habit.name).font(.headline)
                    // Show a bell icon if reminders are enabled
                    if habit.reminderTime != nil {
                        Image(systemName : "bell.fill")
                            .font (.caption)
                            .foregroundStyle(.orange)
                    }
                }

                // Show the current streak count
                Text("🔥 \(StreakCalculator.currentStreak(for: habit)) day streak")
                // For multi-target habits, show progress (e.g. "2/3")
                if habit.targetPerDay > 1 {
                    Text("\(StreakCalculator.isCompletedToday(habit.completions))/\(habit.targetPerDay)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            // Checkmark button — toggles today's completion
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
