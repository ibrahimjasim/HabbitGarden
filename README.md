# HabitGarden

A SwiftUI habit tracker built for iOS. Each habit becomes a plant in an animated garden that grows with your consistency, and pattern-detection "smart insights" surface observations about your behavior.

Built with SwiftUI, SwiftData, and Swift Charts.

---

## Krav uppfyllda / Requirements covered

### Godkänt (G)

| Krav | Implementation |
|---|---|
| Startskärm som listar alla vanor | `HabitListView` with `@Query` from SwiftData |
| Skapa ny vana | `AddHabitView` presented as a `Sheet` |
| Markera som "Utförd" för dagens datum | Toggle button in `HabitRow`, handled by `HabitListViewModel.toggle(...)` |
| Beräkna och visa "Streak" | `StreakCalculator.currentStreak(...)` with same-day deduplication |
| Radera en vana | `.onDelete` swipe action on `List` |
| Standardkomponenter | `NavigationStack`, `List`, `Sheet`, `Form`, SF Symbols throughout |
| Felhantering i gränssnittet | `viewModel.errorMessage` surfaced via `.alert(...)` |
| Git-historik | Continuous commits across the development period |

### Väl Godkänt (VG)

| Krav | Implementation |
|---|---|
| Mappstruktur (Models / Views / ViewModels) | See [Project Structure](#project-structure) below |
| 15+ meaningful Git commits | See `git log --oneline` |
| **Spår 3 — SwiftUI Charts** | `InsightsView` with bar chart, stat cards, and per-habit streaks |

### Bonus (beyond assignment requirements)

- **GardenView** — animated `Canvas` with time-of-day sky and growing plants
- **InsightEngine** — pattern-detection statistics presented as smart insights

---

## Project Structure

```
HabitGarden/
├─ HabitGardenApp.swift          # @main entry point + SwiftData container
├─ ContentView.swift              # legacy stub, can be removed
├─ Models(SwiftData)/
│   ├─ Habit.swift                # @Model class
│   ├─ HabitCompletion.swift      # @Model class
│   └─ Insght.swift                # SmartInsight value type
├─ ViewModels/
│   └─ HabitListViewModel.swift   # add / toggle / delete + error handling
├─ Views/
│   ├─ HabitListView.swift        # main screen: list + toolbar
│   ├─ AddHabitView.swift         # new-habit sheet
│   ├─ InsightsView.swift         # VG Track 3: charts + smart insights
│   └─ GardenView.swift           # bonus: animated canvas garden
├─ Helpers/
│   ├─ StreakCalculater.swift     # streak math (filename pending rename)
│   └─ InsightEngine.swift        # pattern-detection logic
└─ Assets.xcassets
```

---

## Data Schema

```
Habit                                  (SwiftData @Model)
├─ name: String
├─ emoji: String                       # the plant face shown in the Garden
├─ colorHex: String
├─ createdAt: Date
├─ reminderTime: Date?                 # reserved for future Track 2
└─ completions: [HabitCompletion]      # cascade delete relationship
       │
       └── HabitCompletion             (SwiftData @Model)
              ├─ date: Date
              └─ habit: Habit?         # back-reference

SmartInsight                           (value type, not persisted)
├─ id: UUID
├─ title: String
├─ message: String
├─ symbol: String                      # SF Symbol name OR emoji
└─ colorName: String                   # mapped to Color via computed prop
```

**Why a separate `HabitCompletion` model?** It lets us record an exact timestamp per check-in. That timestamp powers the streak calculator, the 7-day chart, and the "best time of day" smart insight. A simple `lastCompleted` field on `Habit` couldn't do any of that.

---

## Architecture

The app follows **MVVM**:

- **Models** (`Habit`, `HabitCompletion`) — `@Model` classes managed by SwiftData. Persistence is automatic; views observe via `@Query`.
- **ViewModel** (`HabitListViewModel`) — `@Observable` class containing mutating actions and an `errorMessage` published property.
- **Views** (`HabitListView`, `AddHabitView`, `InsightsView`, `GardenView`) — pure SwiftUI, no direct database calls, only call into the ViewModel.
- **Helpers** (`StreakCalculator`, `InsightEngine`) — stateless utility structs with `static` methods. Easy to test in isolation.

Errors don't crash the app. Empty habit names, save failures, and other issues surface as user-facing alerts — satisfying the G requirement *"appen ska visa ett tydligt felmeddelande i gränssnittet istället för att stängas ner."*

---

## Build & Run

Requirements: Xcode 15+, iOS 17+ (uses SwiftData and `ContentUnavailableView`).

1. Open `HabitGarden.xcodeproj`.
2. Select an iOS Simulator (iPhone 15 or newer recommended).
3. Press ⌘R to build and run.
4. Tap **+** to add your first habit.
5. Tap the **leaf** icon for the animated Garden, or the **chart** icon for Insights.

---

## Development Log

The project was built iteratively, with each phase committed separately to git.

**Phase 1 — Project setup**
Created the Xcode project with SwiftUI + SwiftData. Initialised the git repo. Decided against Firebase in favour of SwiftData since the assignment specifies "standardkomponenter" and the app is single-user / offline-first.

**Phase 2 — Data model**
Defined `Habit` and `HabitCompletion` as `@Model` classes with a one-to-many cascade-delete relationship.

**Phase 3 — App entry point**
Replaced the boilerplate `sharedModelContainer` with the cleaner `.modelContainer(for:)` scene modifier and pointed the window at `HabitListView`.

**Phase 4 — Streak calculation**
Wrote `StreakCalculator` with two static methods. Handled the midnight edge case so the streak doesn't reset when the user hasn't yet checked off today's habit.

**Phase 5 — ViewModel**
Created `HabitListViewModel` (`@MainActor @Observable`) with `addHabit`, `toggle`, `delete`, and an `errorMessage` property used by the View's alert.

**Phase 6 — Main list screen**
Built `HabitListView` with `NavigationStack`, `List`, swipe-to-delete, and an empty state via `ContentUnavailableView`. Added `HabitRow` showing emoji, name, streak, and a check button.

**Phase 7 — Add habit sheet**
Built `AddHabitView` with a `Form`, a TextField, and an emoji grid picker. Save is disabled until the name is non-empty.

**Phase 8 — Insights (VG Track 3)**
Built `InsightsView` using SwiftUI Charts. Added two stat cards (week total, best streak), a 7-day `BarMark` chart, and a per-habit streak list. Wired into the toolbar via a chart-icon `NavigationLink`.

**Phase 9 — Garden (bonus WOW)**
Built `GardenView` using `Canvas` wrapped in `TimelineView(.animation)` for a continuously redrawing scene. Each habit becomes a plant whose stem height, leaf size, and flower scale come from a 7-day completion ratio. The sky tints based on the system clock (dawn / day / dusk / night).

**Phase 10 — Smart Insights**
Added `InsightEngine` and `SmartInsight`. The engine generates up to four observations: best time of day, best day of week, week-over-week trend, and most-consistent habit. Each insight has a data threshold so it doesn't fire on too little data. `InsightCard` handles both SF Symbol names and emoji glyphs.

---

## What's Next

These are obvious extensions if the project continues past the assignment:

- **Track 2 — UserNotifications**: per-habit reminder time, scheduled with `UNUserNotificationCenter`.
- **Track 1 — MapKit**: log GPS coordinates on completion and show a map of where habits happened.
- **Share garden**: export the Garden canvas as a PNG using `ImageRenderer`.
- **Widget**: a Lock Screen / Home Screen widget showing today's progress, with an interactive App Intent to mark habits done.

---

## Credits

Built by Ibrahim Jasim Alsalih as a course project, May 2026.
