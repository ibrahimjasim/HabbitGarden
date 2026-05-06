//
//  GardenView.swift
//  HabitGarden
//
//  The "WOW" view: each habit becomes a plant whose growth reflects
//  the user's consistency over the last 7 days. Plants sway gently,
//  and the sky tints based on the current time of day.
//
//  Created by Ibrahim Jasim Alsalih on 2026-05-04.
//

import SwiftUI
import SwiftData

struct GardenView: View {
    @Query(sort: \Habit.createdAt) private var habits: [Habit]

    var body: some View {
        ZStack {
            timeOfDayGradient
                .ignoresSafeArea()

            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                Canvas { context, size in
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    drawGarden(context: context, size: size, time: time)
                }
            }

            if habits.isEmpty {
                ContentUnavailableView(
                    "Your garden is empty",
                    systemImage: "leaf.circle",
                    description: Text("Add a habit to plant your first seed.")
                )
            }
        }
        .navigationTitle("Garden")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Background

    private var timeOfDayGradient: LinearGradient {
        let hour = Calendar.current.component(.hour, from: .now)
        let colors: [Color]
        switch hour {
        case 5..<8:
            colors = [.orange.opacity(0.45), .yellow.opacity(0.35), .cyan.opacity(0.30)]
        case 8..<17:
            colors = [.cyan.opacity(0.45), .blue.opacity(0.20), .green.opacity(0.25)]
        case 17..<20:
            colors = [.purple.opacity(0.45), .orange.opacity(0.40), .pink.opacity(0.30)]
        default:
            colors = [.indigo.opacity(0.65), .black.opacity(0.55)]
        }
        return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
    }

    // MARK: - Drawing

    private func drawGarden(context: GraphicsContext, size: CGSize, time: Double) {
        let groundY = size.height * 0.78

        // Sun or moon
        let hour = Calendar.current.component(.hour, from: .now)
        let isNight = hour < 6 || hour >= 20
        let celestialRect = CGRect(x: size.width * 0.78, y: size.height * 0.10,
                                   width: 56, height: 56)
        context.fill(
            Path(ellipseIn: celestialRect),
            with: .color(isNight ? .white.opacity(0.85) : .yellow.opacity(0.9))
        )

        // Ground
        let groundRect = CGRect(x: 0, y: groundY, width: size.width, height: size.height - groundY)
        context.fill(
            Path(groundRect),
            with: .linearGradient(
                Gradient(colors: [.green.opacity(0.55), .brown.opacity(0.75)]),
                startPoint: CGPoint(x: 0, y: groundY),
                endPoint: CGPoint(x: 0, y: size.height)
            )
        )

        // Plants — laid out evenly across the width
        guard !habits.isEmpty else { return }
        let calendar = Calendar.current
        let plantSpacing = size.width / CGFloat(habits.count + 1)

        for (index, habit) in habits.enumerated() {
            let growth = growthLevel(for: habit, calendar: calendar)
            let baseX = plantSpacing * CGFloat(index + 1)
            let phase = time * 1.4 + Double(index) * 0.6
            let sway = sin(phase) * 4 * Double(growth)

            drawPlant(
                context: context,
                baseX: baseX,
                groundY: groundY,
                growth: growth,
                emoji: habit.emoji,
                sway: sway
            )
        }
    }

    private func drawPlant(
        context: GraphicsContext,
        baseX: CGFloat,
        groundY: CGFloat,
        growth: CGFloat,
        emoji: String,
        sway: Double
    ) {
        let maxHeight: CGFloat = 140
        // Always show a tiny sprout, even at 0% growth
        let stemHeight = max(18, maxHeight * growth)
        let topX = baseX + CGFloat(sway)
        let topY = groundY - stemHeight

        // Stem — a soft curve so it looks alive
        var stemPath = Path()
        stemPath.move(to: CGPoint(x: baseX, y: groundY))
        stemPath.addQuadCurve(
            to: CGPoint(x: topX, y: topY),
            control: CGPoint(x: baseX + CGFloat(sway * 0.5), y: groundY - stemHeight * 0.5)
        )
        context.stroke(stemPath, with: .color(.green), lineWidth: 3)

        // Leaves appear once the plant is past the sprout stage
        if growth > 0.3 {
            let leafY = groundY - stemHeight * 0.5
            let leafW: CGFloat = 14 * growth
            let leafH: CGFloat = leafW * 0.6
            context.fill(
                Path(ellipseIn: CGRect(x: baseX - leafW - 2, y: leafY - leafH / 2,
                                       width: leafW, height: leafH)),
                with: .color(.green.opacity(0.85))
            )
            context.fill(
                Path(ellipseIn: CGRect(x: baseX + 2, y: leafY - leafH / 2,
                                       width: leafW, height: leafH)),
                with: .color(.green.opacity(0.85))
            )
        }

        // Flower — the habit's emoji, scaled by growth.
        // If the habit has no emoji, draw a simple flower bud instead so the
        // plant still looks complete.
        if emoji.isEmpty {
            let budSize: CGFloat = 10 + 14 * growth
            context.fill(
                Path(ellipseIn: CGRect(x: topX - budSize / 2,
                                       y: topY - budSize / 2,
                                       width: budSize,
                                       height: budSize)),
                with: .color(.pink.opacity(0.85))
            )
        } else {
            let flowerSize: CGFloat = 22 + 30 * growth
            context.draw(
                Text(emoji).font(.system(size: flowerSize)),
                at: CGPoint(x: topX, y: topY)
            )
        }
    }

    // MARK: - Growth logic

    /// Returns 0.0–1.0 based on completions in the last 7 days.
    private func growthLevel(for habit: Habit, calendar: Calendar) -> CGFloat {
        let last7Days: [Date] = (0..<7).map { offset in
            calendar.startOfDay(for: calendar.date(byAdding: .day, value: -offset, to: .now)!)
        }
        let completedDays = Set(habit.completions.map { calendar.startOfDay(for: $0.date) })
        let hits = last7Days.filter { completedDays.contains($0) }.count
        return CGFloat(hits) / 7.0
    }
}

#Preview {
    NavigationStack { GardenView() }
        .modelContainer(for: [Habit.self, HabitCompletion.self], inMemory: true)
}
