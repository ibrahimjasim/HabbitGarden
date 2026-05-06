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
    @State private var customEmoji = ""

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
                                    customEmoji = ""
                                }
                        }
                    }
                    .padding(.vertical, 4)

                    HStack {
                        Image(systemName: "pencil.tip")
                            .foregroundStyle(.secondary)
                        TextField("Or type your own emoji", text: $customEmoji)
                            .onChange(of: customEmoji) { _, newValue in
                                // Keep only the first grapheme cluster so
                                // compound emojis like 👨‍👩‍👧 still work.
                                guard let first = newValue.first else { return }
                                let single = String(first)
                                if customEmoji != single {
                                    customEmoji = single
                                }
                                emoji = single
                            }
                        if !customEmoji.isEmpty {
                            Text(customEmoji)
                                .font(.title2)
                                .padding(6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.green.opacity(0.25))
                                )
                        }
                    }
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
