//
//  AuthViewModel.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-05-07.
//

import Foundation
import SwiftData
import CryptoKit

// Handles all authentication logic: sign up, sign in, sign out
// @MainActor ensures all UI updates happen on the main thread
// @Observable lets SwiftUI automatically update views when properties change
@MainActor
@Observable
final class AuthViewModel {

    private(set) var currentUser: AppUser?   // The currently logged-in user (nil if not logged in)
    var errorMessage: String?                // Shown in an alert when something goes wrong

    private let storageKey = "habitGarden.currentUser"  // Key for saving user info in UserDefaults

    // On launch, try to restore the previous session so the user stays logged in
    init() {
        loadFromStorage()
    }

    // Quick check used by the app entry point to decide which screen to show
    var isLoggedIn: Bool { currentUser != nil }

    // MARK: - Sign up (create a new account)

    func signUp(name: String, email: String, password: String, context: ModelContext) {
        // Clean up the input
        let trimmedName  = name.trimmingCharacters(in: .whitespaces)
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces).lowercased()

        // Validate all fields before doing anything
        guard !trimmedName.isEmpty else {
            errorMessage = "Please enter your name."; return
        }
        guard trimmedEmail.contains("@"), trimmedEmail.contains(".") else {
            errorMessage = "Please enter a valid email."; return
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."; return
        }

        // Check if an account with this email already exists in the database
        let descriptor = FetchDescriptor<AppAccount>(
            predicate: #Predicate { $0.email == trimmedEmail }
        )
        do {
            if let _ = try context.fetch(descriptor).first {
                errorMessage = "An account with that email already exists."
                return
            }
            // Create a new account and save it to the database
            let account = AppAccount(
                email: trimmedEmail,
                name: trimmedName,
                passwordHash: hash(password)   // Hash the password before storing
            )
            context.insert(account)
            try context.save()

            // Automatically log the user in after signing up
            startSession(for: account)
        } catch {
            errorMessage = "Sign up failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Sign in (log into an existing account)

    func signIn(email: String, password: String, context: ModelContext) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces).lowercased()
        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password."; return
        }

        // Look up the account by email in the database
        let descriptor = FetchDescriptor<AppAccount>(
            predicate: #Predicate { $0.email == trimmedEmail }
        )
        do {
            guard let account = try context.fetch(descriptor).first else {
                errorMessage = "No account found with that email."
                return
            }
            // Compare the hashed password to verify identity
            guard account.passwordHash == hash(password) else {
                errorMessage = "Incorrect password."
                return
            }
            startSession(for: account)
        } catch {
            errorMessage = "Sign in failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Sign out

    func signOut() {
        currentUser = nil                                       // Clear the in-memory user
        UserDefaults.standard.removeObject(forKey: storageKey)  // Remove saved session
    }

    // MARK: - Private helpers

    // After successful sign-in/sign-up, save user info so the app remembers them
    private func startSession(for account: AppAccount) {
        let user = AppUser(
            id: account.id.uuidString,
            name: account.name,
            email: account.email
        )
        currentUser = user
        // Save to UserDefaults so the session persists between app launches
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    // Try to restore the user from UserDefaults on app launch
    private func loadFromStorage() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let user = try? JSONDecoder().decode(AppUser.self, from: data) else {
            return
        }
        currentUser = user
    }

    // Converts a plain-text password into a SHA-256 hash for secure storage
    private func hash(_ password: String) -> String {
        let digest = SHA256.hash(data: Data(password.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
