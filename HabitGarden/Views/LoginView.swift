//
//  LoginView.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-05-07.
//

import SwiftUI

struct LoginView: View {
    let auth: AuthViewModel
    
    @State private var name = ""
    @State private var emil = ""
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 12) {
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size:80))
                    .foregroundStyle(.green)
                Text("HabitGarden")
                    .font(.largeTitle.bold())
                Text("Gorw your habits, one day at a time.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
            }
            
            VStack(spacing: 16) {
                TextField("Your name", text: $name)
                    .textContentType(.name)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.secondarySystemBackground))
                            
                    )
                
                Button {
                    auth.signIn(name: name, email: emil)
                } label: {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .alert(
            "Could not sign in",
            isPresented: .constant(auth.errorMessage != nil)
        ) {
            Button("OK") {
                auth.errorMessage = nil
            }
        } message: {
            Text(auth.errorMessage ?? "")
        }
    }
}

#Preview {
    LoginView(auth: AuthViewModel())
}
