//
//  AddHabitView.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-05-04.
//

import SwiftUI
import SwiftData

// Form to create a new habit — presented as a sheet from HabitListView
struct AddHabitView: View {
    @Environment(\.modelContext) private var context       // Database access
    @Environment(\.dismiss) private var dismiss            // Closes this sheet
    @Environment(AuthViewModel.self) private var auth      // Current user (to link the habit)

    let viewModel: HabitListViewModel

    // Form state
    @State private var name = ""
    @State private var emoji = "🌱"
    @State private var showEmojiPicker = false
    @State private var targetPerDay = 1
    @State private var enableReminders = false
    @State private var reminderTime = Calendar.current.date(
        bySettingHour: 8, minute: 0, second: 0, of: .now) ?? .now
    @State private var enableGoal = false
    @State private var goalDays = 30

    // Quick-pick emoji presets shown in the grid
    private let emojis = ["🌱", "💧", "📚", "🏃", "🧘", "💤", "🥗", "✍️", "🎨", "🎵"]

    // True when the user picked an emoji from the full picker (not from the presets)
    private var emojiIsCustom: Bool {
        !emoji.isEmpty && !emojis.contains(emoji)
    }

    @ViewBuilder
    private var symbolSection: some View {
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

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("e.g. Morning walk", text: $name)
                }
                
                Section("How many times per day?") {
                    Stepper("\(targetPerDay) time\(targetPerDay == 1 ? "" : "s")", value: $targetPerDay, in: 1...20)
                }
                Section("Goal duration"){
                    Toggle("Set a goal", isOn: $enableGoal)
                    if enableGoal {
                        Stepper("\(goalDays) days", value: $goalDays, in: 7...365, step: 7)
                        Text("e.g. quit smoking in \(goalDays) days")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Symbol") {
                    symbolSection
                }
                
                Section ("Reminder") {
                    Toggle("Daily reminder", isOn: $enableReminders)
                    if enableReminders {
                        DatePicker("Time", selection: $reminderTime,
                                   displayedComponents: .hourAndMinute)
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
                        viewModel.addHabit(
                            name: name,
                            emoji: emoji,
                            targetPerDay: targetPerDay,
                            goalDays: enableGoal ? goalDays : nil,
                            reminderTime: enableReminders ? reminderTime : nil,
                            userId: auth.currentUser?.id ?? "",
                            context: context
                        )
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
            .alert(
                "Something went wrong",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                )
            ) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
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
