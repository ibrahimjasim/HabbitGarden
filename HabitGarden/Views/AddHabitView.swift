//
//  AddHabitView.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-05-04.
//

import SwiftUI
import SwiftData

struct AddHabitView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let viewModel: HabitListViewModel

    @State private var name = ""
    @State private var emoji = "🌱"

    private let emojis = ["🌱", "💧", "📚", "🏃", "🧘", "💤", "🥗", "✍️", "🎨", "🎵"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("e.g. Morning walk", text: $name)
                }

                Section("Symbol") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5)) {
                        ForEach(emojis, id: \.self) { item in
                            Text(item)
                                .font(.largeTitle)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(emoji == item ? Color.green.opacity(0.25) : .clear)
                                )
                                .onTapGesture {
                                    emoji = item
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("New habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addHabit(name: name, emoji: emoji, context: context)
                        if viewModel.errorMessage == nil {
                            dismiss()
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddHabitView(viewModel: HabitListViewModel())
        .modelContainer(for: [Habit.self, HabitCompletion.self], inMemory: true)
}
