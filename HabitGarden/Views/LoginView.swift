//
//  LoginView.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-05-07.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    let auth: AuthViewModel
    @Environment(\.modelContext) private var context

    private enum Mode: String, CaseIterable, Identifiable {
        case signIn = "Sign In"
        case signUp = "Sign Up"
        var id: Self { self }
    }

    @State private var mode: Mode = .signIn
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""

    private var canSubmit: Bool {
        let baseValid = !email.isEmpty && !password.isEmpty
        return mode == .signIn ? baseValid : (baseValid && !name.isEmpty)
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(.green)
                Text("HabitGarden")
                    .font(.largeTitle.bold())
                Text("Grow your habits, one day at a time.")
                    .foregroundStyle(.secondary)
            }

            Picker("Mode", selection: $mode) {
                ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

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

            Spacer()
        }
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
