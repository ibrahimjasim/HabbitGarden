//
//  HabitListView.swift
//  HabitGarden
//

import SwiftUI
import SwiftData

struct HabitListView: View {
    @Environment(\.modelContext) private var context
    @Environment(AuthViewModel.self) private var auth
    @Query(sort: \Habit.createdAt) private var habits: [Habit]
    @State private var viewModel = HabitListViewModel()
    @State private var showAddSheet = false
    @State private var showDeleteAccountConfirm = false

    private var userHabits: [Habit] {
        guard let userId = auth.currentUser?.id else { return [] }
        return habits.filter { $0.userId == userId }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BaseplateBackground()

                VStack(spacing: 0) {
                    header

                    if userHabits.isEmpty {
                        Spacer()
                        ContentUnavailableView(
                            "No habits yet",
                            systemImage: "leaf",
                            description: Text("Tap + to add your first habit.")
                        )
                        Spacer()
                    } else {
                        List {
                            ForEach(userHabits) { habit in
                                NavigationLink(destination: HabitDetailView(habit: habit)) {
                                    HabitRow(habit: habit) {
                                        viewModel.toggle(habit: habit, context: context)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    viewModel.delete(habit: userHabits[index], context: context)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showAddSheet) {
                AddHabitView(viewModel: viewModel)
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
            .confirmationDialog(
                "Delete your account?",
                isPresented: $showDeleteAccountConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete Account", role: .destructive) {
                    auth.deleteAccount(context: context)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently deletes your habits and your account. This can't be undone.")
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Habits").font(.brickTitle(30)).foregroundStyle(Brick.ink)
                Text("\(userHabits.count) growing today")
                    .font(.brickBody(14)).foregroundStyle(Brick.ink.opacity(0.75))
            }
            Spacer()
            HStack(spacing: 8) {
                NavigationLink { InsightsView() } label: {
                    iconGlyph("chart.bar.fill", tint: Brick.blue)
                }
                NavigationLink { GardenView() } label: {
                    iconGlyph("leaf.fill", tint: Brick.green)
                }
                Menu {
                    Button { auth.signOut() } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                    Button(role: .destructive) { showDeleteAccountConfirm = true } label: {
                        Label("Delete Account", systemImage: "trash")
                    }
                } label: {
                    iconGlyph("person.crop.circle", tint: Brick.white)
                }
                Button { showAddSheet = true } label: {
                    iconGlyph("plus", tint: Brick.yellow)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 6)
    }

    private func iconGlyph(_ systemImage: String, tint: Color) -> some View {
        Image(systemName: systemImage)
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(tint.brickTextColor)
            .frame(width: 40, height: 40)
            .brickCard(fill: tint, cornerRadius: 11, borderWidth: 2.5, shadowOffset: 4)
            .overlay(BrickStuds(count: 2, diameter: 7, color: tint), alignment: .top)
    }
}

// A single habit card — colored by the habit's own colorHex.
struct HabitRow: View {
    let habit: Habit
    let onToggle: () -> Void

    private var cardColor: Color { Color(hex: habit.colorHex) }
    private var textColor: Color { cardColor.brickTextColor }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Brick.white)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Brick.ink, lineWidth: 2))
                if habit.emoji.isEmpty {
                    Image(systemName: "circle.dashed").foregroundStyle(.secondary)
                } else {
                    Text(habit.emoji).font(.system(size: 26))
                }
            }
            .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(habit.name).font(.brickHeading(17)).foregroundStyle(textColor)
                    if habit.reminderTime != nil {
                        Image(systemName: "bell.fill")
                            .font(.caption2)
                            .foregroundStyle(textColor.opacity(0.85))
                    }
                }
                Text("🔥 \(StreakCalculator.currentStreak(for: habit)) day streak")
                    .font(.brickBody(13))
                    .foregroundStyle(textColor.opacity(0.92))
                if habit.targetPerDay > 1 {
                    Text("\(StreakCalculator.isCompletedToday(habit.completions))/\(habit.targetPerDay)")
                        .font(.brickBodyHeavy(11))
                        .foregroundStyle(textColor.opacity(0.9))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Brick.ink.opacity(0.18)))
                }
            }

            Spacer()

            Button(action: onToggle) {
                Image(systemName: StreakCalculator.isCompletedToday(habit)
                      ? "checkmark"
                      : (habit.targetPerDay > 1 ? "plus" : "circle"))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Brick.ink)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Brick.white))
                    .overlay(Circle().stroke(Brick.ink, lineWidth: 2.5))
                    .compositingGroup()
                    .shadow(color: Brick.ink, radius: 0, x: 3, y: 3)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .brickCard(fill: cardColor, cornerRadius: 18, borderWidth: 3, shadowOffset: 5)
        .overlay(BrickStuds(count: 3, diameter: 10, color: cardColor), alignment: .top)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())
    }
}

#Preview {
    HabitListView()
        .modelContainer(for: [Habit.self, HabitCompletion.self], inMemory: true)
}
