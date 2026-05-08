//
//  AuthViewModel.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-05-07.
//

import Foundation
import SwiftData
import CryptoKit

@MainActor
@Observable
final class AuthViewModel {

    private(set) var currentUser: AppUser?
    var errorMessage: String?

    private let storageKey = "habitGarden.currentUser"

    init() {
        loadFromStorage()
    }

    var isLoggedIn: Bool { currentUser != nil }

    // MARK: - Sign up

    func signUp(name: String, email: String, password: String, context: ModelContext) {
        let trimmedName  = name.trimmingCharacters(in: .whitespaces)
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces).lowercased()

        guard !trimmedName.isEmpty else {
            errorMessage = "Please enter your name."; return
        }
        guard trimmedEmail.contains("@"), trimmedEmail.contains(".") else {
            errorMessage = "Please enter a valid email."; return
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."; return
        }

        // Reject duplicate emails
        let descriptor = FetchDescriptor<AppAccount>(
            predicate: #Predicate { $0.email == trimmedEmail }
        )
        do {
            if let _ = try context.fetch(descriptor).first {
                errorMessage = "An account with that email already exists."
                return
            }
            let account = AppAccount(
                email: trimmedEmail,
                name: trimmedName,
                passwordHash: hash(password)
            )
            context.insert(account)
            try context.save()

            // Sign them in immediately.
            startSession(for: account)
        } catch {
            errorMessage = "Sign up failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Sign in

    func signIn(email: String, password: String, context: ModelContext) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces).lowercased()
        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password."; return
        }

        let descriptor = FetchDescriptor<AppAccount>(
            predicate: #Predicate { $0.email == trimmedEmail }
        )
        do {
            guard let account = try context.fetch(descriptor).first else {
                errorMessage = "No account found with that email."
                return
            }
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
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    // MARK: - Private

    private func startSession(for account: AppAccount) {
        let user = AppUser(
            id: account.id.uuidString,
            name: account.name,
            email: account.email
        )
        currentUser = user
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadFromStorage() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let user = try? JSONDecoder().decode(AppUser.self, from: data) else {
            return
        }
        currentUser = user
    }

    /// SHA-256 hash of the password as a hex string.
    private func hash(_ password: String) -> String {
        let digest = SHA256.hash(data: Data(password.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
