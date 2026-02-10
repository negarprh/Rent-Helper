//
//  SignupView.swift
//  RentHelper
//
//  Created by Negar Pirasteh on 2026-02-09.
//
import SwiftUI

struct SignupView: View {
    @EnvironmentObject var auth: AuthService

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    let onSwitchToLogin: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            VStack(spacing: 6) {
                Text("Create Account")
                    .font(.largeTitle)
                    .bold()
                Text("Sign up to start saving favorites")
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 12) {
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)

                SecureField("Password (min 6 chars)", text: $password)
                    .textContentType(.newPassword)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }
            .padding(.top, 8)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }

            Button {
                errorMessage = nil

                let e = email.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !e.isEmpty, !password.isEmpty else {
                    errorMessage = "Email and password are required."
                    return
                }

                isLoading = true
                auth.signUp(email: e, password: password) { err in
                    isLoading = false
                    errorMessage = err
                }
            } label: {
                HStack {
                    Spacer()
                    Text(isLoading ? "Creating..." : "Create Account")
                        .bold()
                    Spacer()
                }
                .padding()
                .background(isLoading ? Color.gray.opacity(0.4) : Color.accentColor)
                .foregroundStyle(.white)
                .cornerRadius(12)
            }
            .disabled(isLoading)

            Button {
                onSwitchToLogin()
            } label: {
                Text("Already have an account? Sign in")
                    .font(.footnote)
            }
            .padding(.top, 4)

            Spacer()
        }
        .padding()
        .navigationBarHidden(true)
    }
}
