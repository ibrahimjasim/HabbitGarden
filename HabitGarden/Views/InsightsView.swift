//
//  InsightsView.swift
//  HabitGarden
//
//  VG Track 3 — Data & Statistics with SwiftUI Charts
//  Created by Ibrahim Jasim Alsalih on 2026-05-04.
//

import SwiftUI
import SwiftData
import Charts

struct InsightsView: View {
    @Query private var habits: [Habit]

    /// Returns total completions per day for the last 7 days,
    /// oldest first so the chart reads left-to-right naturally.
    private var last7Days: [DailyCount] {
        let calendar = Calendar.current
        let allCompletions = habits.flatMap { $0.completions }

        return (0..<7).reversed().map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: .now)!
            let start = calendar.startOfDay(for: day)
            let count = allCompletions.filter {
                calendar.isDate($0.date, inSameDayAs: start)
            }.count
            return DailyCount(date: start, count: count)
        }
    }
    

    /// Total completions across all habits this week — for the headline number.
    private var weekTotal: Int {
        last7Days.reduce(0) { $0 + $1.count }
    }

    /// Longest current streak across all habits — the "best of" stat.
    private var bestStreak: Int {
        habits
            .map { StreakCalculator.currentStreak(completions: $0.completions) }
            .max() ?? 0
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // MARK: Headline cards
                HStack(spacing: 12) {
                    StatCard(
                        title: "This week",
                        value: "\(weekTotal)",
                        subtitle: "completions",
                        symbol: "checkmark.seal.fill",
                        color: .green
                    )
                    StatCard(
                        title: "Best streak",
                        value: "\(bestStreak)",
                        subtitle: "days",
                        symbol: "flame.fill",
                        color: .orange
                    )
                }

                // MARK: 7-day bar chart
                VStack(alignment: .leading, spacing: 8) {
                    Text("Last 7 days")
                        .font(.headline)
                    Chart(last7Days) { item in
                        BarMark(
                            x: .value("Day", item.date, unit: .day),
                            y: .value("Completed", item.count)
                        )
                        .foregroundStyle(.green.gradient)
                        .cornerRadius(6)
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { value in
                            AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                        }
                    }
                    .frame(height: 220)
                }

                // MARK: Per-habit streaks
                VStack(alignment: .leading, spacing: 12) {
                    Text("Streaks per habit")
                        .font(.headline)

                    if habits.isEmpty {
                        Text("Add a habit to see your stats here.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(habits) { habit in
                            HStack {
                                Text(habit.emoji)
                                    .font(.title3)
                                Text(habit.name)
                                Spacer()
                                Label(
                                    "\(StreakCalculator.currentStreak(completions: habit.completions))",
                                    systemImage: "flame.fill"
                                )
                                .foregroundStyle(.orange)
                                .font(.subheadline.bold())
                            }
                            .padding(.vertical, 4)
                            Divider()
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Insights")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Helpers

/// One day worth of completion data, used as the Chart data type.
private struct DailyCount: Identifiable {
    var id: Date { date }
    let date: Date
    let count: Int
}

/// A small reusable card for top-level stats.
private struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let symbol: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: symbol)
                .font(.caption)
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 36, weight: .bold, design: .rounded))
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        InsightsView()
    }
    .modelContainer(for: [Habit.self, HabitCompletion.self], inMemory: true)
}
