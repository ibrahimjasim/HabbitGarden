//
//  HabitDetailView.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-05-06.
//

import SwiftData
import SwiftUI

// Detail/edit screen for a single habit — reached by tapping a habit in the list
struct HabitDetailView: View {
    @Bindable var habit: Habit                               // The habit being edited
    @Environment(\.modelContext) private var context          // Database access
    @Environment(\.dismiss) private var dismiss               // Go back to the list

    // Local copies of the habit's properties for editing
    @State private var name: String
    @State private var emoji: String
    @State private var showEmojiPicker = false

    init(habit: Habit) {
        self.habit = habit
        _name = State(initialValue: habit.name)
        _emoji = State(initialValue: habit.emoji)
    }

    var body: some View {
        Form {
            // Editable name field
            Section("Name") {
                TextField("Habit name", text: $name)
            }

            // Tap to change the emoji via a picker sheet
            Section("Emoji") {
                Button {
                    showEmojiPicker = true
                } label: {
                    HStack {
                        Text(emoji)
                            .font(.largeTitle)
                        Spacer()
                        Text("Change")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Read-only statistics about this habit
            Section("Stats") {
                LabeledContent("Streak", value: "\(StreakCalculator.currentStreak(for: habit)) days")
                LabeledContent("Total completions", value: "\(habit.completions.count)")
                LabeledContent("Target per day", value: "\(habit.targetPerDay)")
                LabeledContent("Created", value: habit.createdAt.formatted(date: .abbreviated, time: .omitted))
            }

            // Save changes and go back
            Section {
                Button("Save") {
                    habit.name = name
                    habit.emoji = emoji
                    try? context.save()
                    dismiss()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .navigationTitle("Edit Habit")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEmojiPicker) {
            EmojiPickerView(selectedEmoji: $emoji)
        }
    }
}
