# User Stories — HabitGarden

## Epic 1: Authentication

| ID | User Story | Acceptance Criteria | Priority |
|----|-----------|---------------------|----------|
| US-01 | As a **new user**, I want to **create an account** so that I can **save my habits privately**. | Sign up form with name, email, and password. Duplicate emails are rejected. Password must be 6+ characters. User is auto-logged in after sign up. | Must Have |
| US-02 | As a **returning user**, I want to **sign in with my email and password** so that I can **access my habits**. | Sign in form validates credentials against stored accounts. Wrong password shows an error. Non-existent email shows an error. | Must Have |
| US-03 | As a **logged-in user**, I want to **stay signed in when I reopen the app** so that I **don't have to log in every time**. | Session is saved to UserDefaults. On app launch, the user is restored automatically. | Must Have |
| US-04 | As a **logged-in user**, I want to **sign out** so that I can **switch to a different account**. | Sign out button in the toolbar. Clears the session and returns to the login screen. | Must Have |

---

## Epic 2: Habit Management

| ID | User Story | Acceptance Criteria | Priority |
|----|-----------|---------------------|----------|
| US-05 | As a **user**, I want to **create a new habit** so that I can **start tracking it daily**. | Form with name, emoji picker, daily target, and optional reminder. Habit is saved to the database and appears in the list. | Must Have |
| US-06 | As a **user**, I want to **choose an emoji for my habit** so that I can **visually identify it quickly**. | Quick-pick grid with 10 presets. "Browse more" button opens a full picker with 100+ emojis in 6 categories. "None" option to remove the emoji. | Should Have |
| US-07 | As a **user**, I want to **set a daily target** (e.g. 3 times per day) so that I can **track multi-completion habits**. | Stepper allows 1–20 per day. Progress shows as "2/3" in the habit row. Streak only counts days where the target is fully met. | Should Have |
| US-08 | As a **user**, I want to **edit an existing habit** so that I can **update its name or emoji**. | Tap a habit to open the detail screen. Edit name and emoji. Save updates the database. | Must Have |
| US-09 | As a **user**, I want to **delete a habit** so that I can **remove habits I no longer track**. | Swipe-to-delete on the habit list. Deleting a habit removes all its completions and cancels its notification. | Must Have |

---

## Epic 3: Daily Tracking

| ID | User Story | Acceptance Criteria | Priority |
|----|-----------|---------------------|----------|
| US-10 | As a **user**, I want to **mark a habit as completed today** so that I can **track my daily progress**. | Tap the checkmark button to add a completion. Icon changes to a filled checkmark. | Must Have |
| US-11 | As a **user**, I want to **undo a completion** so that I can **fix accidental taps**. | Tapping the checkmark on an already-completed habit removes the most recent completion for today. | Should Have |
| US-12 | As a **user**, I want to **see my current streak** so that I can **stay motivated by my consistency**. | Each habit row shows "X day streak". The streak doesn't reset if the user hasn't completed today's habit yet. | Must Have |

---

## Epic 4: Reminders

| ID | User Story | Acceptance Criteria | Priority |
|----|-----------|---------------------|----------|
| US-13 | As a **user**, I want to **enable a daily reminder for a habit** so that I **don't forget to complete it**. | Toggle and time picker in the Add Habit form. A daily notification is scheduled at the chosen time. | Should Have |
| US-14 | As a **user**, I want **reminders to stop when I delete a habit** so that I **don't get notifications for removed habits**. | Deleting a habit cancels its pending notification automatically. | Should Have |

---

## Epic 5: Garden View

| ID | User Story | Acceptance Criteria | Priority |
|----|-----------|---------------------|----------|
| US-15 | As a **user**, I want to **see my habits as plants in a garden** so that I can **visualise my progress in a fun way**. | Each habit is drawn as a plant. Plant height reflects 7-day completion rate (0–100%). Plants are spaced evenly across the screen. | Could Have |
| US-16 | As a **user**, I want to **see plants sway gently** so that the **garden feels alive and engaging**. | Plants animate with a sine-wave sway at 30fps using Canvas and TimelineView. | Could Have |
| US-17 | As a **user**, I want the **garden sky to change based on time of day** so that it **feels dynamic and personal**. | Background gradient changes for sunrise (5–8), daytime (8–17), sunset (17–20), and night (20–5). Sun or moon is drawn accordingly. | Could Have |

---

## Epic 6: Insights & Statistics

| ID | User Story | Acceptance Criteria | Priority |
|----|-----------|---------------------|----------|
| US-18 | As a **user**, I want to **see a 7-day bar chart of my completions** so that I can **track my weekly activity**. | Bar chart using Swift Charts shows completions per day for the last 7 days. X-axis shows abbreviated weekday names. | Must Have |
| US-19 | As a **user**, I want to **see headline stats** (weekly total, best streak) so that I can **quickly gauge my performance**. | Two stat cards at the top of the Insights screen showing "This week: X completions" and "Best streak: X days". | Must Have |
| US-20 | As a **user**, I want to **see smart insights about my habits** so that I can **learn from my behavior patterns**. | InsightEngine generates up to 4 insights: best time of day, best day of week, weekly trend, and most consistent habit. Insights only appear when there's enough data. | Should Have |
| US-21 | As a **user**, I want to **see streak counts per habit** so that I can **identify which habits need more attention**. | Per-habit streak list at the bottom of the Insights screen with flame icon and streak number. | Should Have |

---

## Epic 7: Data & Privacy

| ID | User Story | Acceptance Criteria | Priority |
|----|-----------|---------------------|----------|
| US-22 | As a **user**, I want **my data stored locally on my device** so that I **don't need an internet connection or external account**. | All data is stored using SwiftData (local SQLite). No network calls. No third-party services. | Must Have |
| US-23 | As a **user**, I want **my password stored securely** so that **my account is protected**. | Passwords are hashed with SHA-256 before storage. Plain text passwords are never saved to the database. | Must Have |
| US-24 | As a **user**, I want to **only see my own habits** so that **other users on the same device can't see my data**. | Habits are filtered by the current user's ID. Each account has a completely separate set of habits. | Must Have |

---

## MoSCoW Summary

| Priority | Count | Stories |
|----------|-------|---------|
| **Must Have** | 13 | US-01, US-02, US-03, US-04, US-05, US-08, US-09, US-10, US-12, US-18, US-19, US-22, US-23, US-24 |
| **Should Have** | 7 | US-06, US-07, US-11, US-13, US-14, US-20, US-21 |
| **Could Have** | 3 | US-15, US-16, US-17 |
| **Won't Have** | 0 | — |

All user stories have been implemented and tested.
