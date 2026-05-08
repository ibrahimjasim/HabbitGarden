//
//  NotificationManager.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-05-06.
//

import Foundation
import UserNotifications

// Manages push notifications — daily reminders for each habit
struct NotificationManager {

    // Asks the user for permission to show notifications (called once on app launch)
    static func requestNotificationPermission() async {
        do {
            try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            print("Notification permission request failed: \(error)")
        }
    }

    // Schedules a repeating daily notification at the chosen time
    static func schedule(habitId: String, name: String, emoji: String, time: Date) {
        // Build the notification content (what the user sees)
        let content = UNMutableNotificationContent()
        content.title = emoji.isEmpty ? "Habit reminder" : "\(emoji) \(name)"
        content.body = "Did you complete your \(name) today?"
        content.sound = .default

        // Extract hour and minute so it repeats every day at the same time
        let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)

        // Use the habit's ID so we can cancel this specific notification later
        let request = UNNotificationRequest(identifier: habitId, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error { print ("Error scheduling notification: \(error)")

            }
        }
    }

    // Cancels the daily reminder when a habit is deleted
    static func cancel(habitId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [habitId])
    }

}
