//
//  AuthViewModel.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-05-07.
//

import Foundation


@MainActor
@Observable

final class AuthViewModel {
    private(set) var currentUser: AppUser?
    var errorMessage: String?
    
    private let storageKey = "habbitGarden.currentUser"
    
    init() {
        loadFromStorage()
    }
    
    var isLoggedIn: Bool {
        currentUser != nil
    }
    
    /// Creates a local user with the typed name + optional email.
    func signIn(name: String, email: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            errorMessage = "Name is required"
            return
        }
        let user = AppUser(
            id: UUID().uuidString,
            name: trimmedName,
            email: email.isEmpty ? nil : email
        )
        saveUser(user)
    }
    
    // MARK: Persistence
    
    private func saveUser(_ user: AppUser) {
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
}
