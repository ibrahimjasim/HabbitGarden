//
//  NotificationManager.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-05-06.
//

import Foundation
import UserNotifications

struct NotificationManager {
    
    static func requestNotificationPermission() async {
        do {
            try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            print("Notification permission request failed: \(error)")
        }
    }
    
    /// Schedules a daily reminder at the given time. Identifier is the
    static func schedule(habitId: String, name: String, emoji: String, time: Date) {
        let content = UNMutableNotificationContent()
        content.title = emoji.isEmpty ? "Habit reminder" : "\(emoji) \(name)"
        content.body = "Did you complete your \(name) today?"
        content.sound = .default
        
        let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        
        let request = UNNotificationRequest(identifier: habitId, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error { print ("Error scheduling notification: \(error)")

            }
        }
    }

    /// Removes any pending reminder for this habit ID.
    static func cancel(habitId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [habitId])
    }

}
