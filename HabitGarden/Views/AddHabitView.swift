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
    @State private var showEmojiPicker = false
    @State private var targetPerDay = 1

    private let emojis = ["🌱", "💧", "📚", "🏃", "🧘", "💤", "🥗", "✍️", "🎨", "🎵"]

    /// True when the chosen emoji isn't one of the quick presets and isn't empty.
    private var emojiIsCustom: Bool {
        !emoji.isEmpty && !emojis.contains(emoji)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("e.g. Morning walk", text: $name)
                }
                
                Section("How many times per day?") {
                    Stepper("\(targetPerDay) time\(targetPerDay == 1 ? "" : "s")", value: $targetPerDay, in: 1...20)
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

                    HStack(spacing: 8) {
                        Button {
                            showEmojiPicker = true
                        } label: {
                            HStack {
                                Image(systemName: "face.smiling")
                                Text("Browse more")
                                if emojiIsCustom {
                                    Spacer()
                                    Text(emoji)
                                        .font(.title3)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.tertiarySystemBackground))
                            )
                        }
                        .buttonStyle(.plain)

                        Button {
                            emoji = ""
                        } label: {
                            HStack {
                                Image(systemName: "circle.slash")
                                Text("None")
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(emoji.isEmpty
                                          ? Color.green.opacity(0.25)
                                          : Color(.tertiarySystemBackground))
                            )
                        }
                        .buttonStyle(.plain)
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
            .sheet(isPresented: $showEmojiPicker) {
                EmojiPickerSheet(selection: $emoji)
            }
        }
    }
}

// MARK: - Emoji picker sheet

/// A categorised grid of emojis. Tap one and the sheet dismisses with
/// the binding updated to the chosen emoji.
private struct EmojiPickerSheet: View {
    @Binding var selection: String
    @Environment(\.dismiss) private var dismiss

    private let categories: [(name: String, emojis: [String])] = [
        ("Faces & people", [
            "😀", "😎", "🤩", "🥳", "🤓", "😇", "🤗", "🥰",
            "😴", "🤔", "🙏", "👋", "💪", "🧠", "👀", "👶"
        ]),
        ("Activities", [
            "🏃", "🧘", "🏋️", "🚴", "🏊", "🤸", "🚶", "🏆",
            "⚽️", "🏀", "🎾", "🎮", "🎯", "🎲", "🎤", "🎧"
        ]),
        ("Food & drink", [
            "🍎", "🍌", "🍓", "🥗", "🥑", "🥦", "🌽", "🍞",
            "🍕", "🍣", "🥛", "☕️", "🍵", "🍷", "🧃", "💊"
        ]),
        ("Nature", [
            "🌱", "🌿", "🍀", "🌳", "🌲", "🌵", "🌷", "🌸",
            "🌹", "🌻", "🌼", "🌞", "🌝", "⭐️", "🌟", "✨",
            "🔥", "💧", "🌊", "❄️"
        ]),
        ("Objects", [
            "📚", "📖", "✍️", "🎨", "🎵", "🎶", "🎸", "💻",
            "📱", "⌚️", "📷", "🔬", "🧪", "💡", "🔑", "💰",
            "💼", "🛏", "🚿", "🧴", "🧼", "🧹"
        ]),
        ("Symbols", [
            "❤️", "💛", "💚", "💙", "💜", "🤍", "🖤", "💯",
            "✅", "✔️", "⚡️", "🌈", "☀️", "☁️", "🎯", "💎", "👑"
        ])
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 6)

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(categories, id: \.name) { category in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(category.name)
                                .font(.headline)
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(category.emojis, id: \.self) { item in
                                    Button {
                                        selection = item
                                        dismiss()
                                    } label: {
                                        Text(item)
                                            .font(.system(size: 32))
                                            .frame(width: 44, height: 44)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(selection == item
                                                          ? Color.green.opacity(0.25)
                                                          : Color(.tertiarySystemBackground))
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Choose emoji")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    AddHabitView(viewModel: HabitListViewModel())
        .modelContainer(for: [Habit.self, HabitCompletion.self], inMemory: true)
}
