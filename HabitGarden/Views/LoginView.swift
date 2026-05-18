//
//  LoginView.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-05-07.
//

import SwiftUI
import SwiftData
import AuthenticationServices

// The login/sign-up screen — shown when the user is not logged in
struct LoginView: View {
    let auth: AuthViewModel                                 // Passed from the app entry point
    @Environment(\.modelContext) private var context         // Database access for creating accounts

    // Toggle between Sign In and Sign Up mode
    private enum Mode: String, CaseIterable, Identifiable {
        case signIn = "Sign In"
        case signUp = "Sign Up"
        var id: Self { self }
    }

    @State private var mode: Mode = .signIn
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""

    // Button is only enabled when all required fields are filled
    private var canSubmit: Bool {
        let baseValid = !email.isEmpty && !password.isEmpty
        return mode == .signIn ? baseValid : (baseValid && !name.isEmpty)
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // App logo and tagline
            VStack(spacing: 12) {
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(.green)
                Text("HabitGarden")
                    .font(.largeTitle.bold())
                Text("Grow your habits, one day at a time.")
                    .foregroundStyle(.secondary)
            }

            // Segmented control to switch between Sign In / Sign Up
            Picker("Mode", selection: $mode) {
                ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            // Input fields — name only appears in Sign Up mode
            VStack(spacing: 12) {
                if mode == .signUp {
                    TextField("Your name", text: $name)
                        .textContentType(.name)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                SecureField("Password", text: $password)
                    .textContentType(mode == .signUp ? .newPassword : .password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal)

            // Submit button — calls the appropriate auth method based on mode
            Button {
                switch mode {
                case .signIn:
                    auth.signIn(email: email, password: password, context: context)
                case .signUp:
                    auth.signUp(name: name, email: email,
                                password: password, context: context)
                }
            } label: {
                Text(mode == .signIn ? "Sign In" : "Create account")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(canSubmit ? Color.green : Color.gray)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(!canSubmit)
            .padding(.horizontal)

            // Divider between email/password and Apple sign in
            HStack {
                Rectangle().frame(height: 1).foregroundStyle(.secondary.opacity(0.3))
                Text("or")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Rectangle().frame(height: 1).foregroundStyle(.secondary.opacity(0.3))
            }
            .padding(.horizontal)

            // Sign in with Apple button
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                auth.handleAppleSignIn(result: result, context: context)
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)

            Spacer()
        }
        // Error alert — shown when auth fails (wrong password, duplicate email, etc.)
        .alert(
            "Could not continue",
            isPresented: Binding(
                get: { auth.errorMessage != nil },
                set: { if !$0 { auth.errorMessage = nil } }
            )
        ) {
            Button("OK") { auth.errorMessage = nil }
        } message: {
            Text(auth.errorMessage ?? "")
        }
    }
}

#Preview {
    LoginView(auth: AuthViewModel())
        .modelContainer(for: [Habit.self, HabitCompletion.self, AppAccount.self], inMemory: true)
}
