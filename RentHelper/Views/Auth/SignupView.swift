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
    @FocusState private var focusedField: Field?

    enum Field {
        case email
        case password
    }

    var body: some View {
        ZStack {
            AppPageBackground()

            VStack(spacing: 18) {
                Spacer(minLength: 32)

                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 54))
                        .foregroundStyle(AppTheme.accent)

                    Text("Create Account")
                        .font(.system(size: 34, weight: .bold, design: .rounded))

                    Text("Join to save favorites and track deposits")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .focused($focusedField, equals: .email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(.white, in: RoundedRectangle(cornerRadius: 12))

                    SecureField("Password (min 6 chars)", text: $password)
                        .focused($focusedField, equals: .password)
                        .textContentType(.newPassword)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(.white, in: RoundedRectangle(cornerRadius: 12))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(AppTheme.danger)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }

                Button {
                    focusedField = nil
                    signUp()
                } label: {
                    HStack {
                        Spacer()
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(isLoading ? "Creating..." : "Create Account")
                            .bold()
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .background(isLoading ? Color.gray.opacity(0.4) : AppTheme.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isLoading)

                Divider()

                Button {
                    onSwitchToLogin()
                } label: {
                    Text("Already have an account? Sign in")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.accent)
                }

                Spacer(minLength: 10)
            }
            .padding(22)
            .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.9), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 14, y: 6)
            .padding(.horizontal, 22)
        }
        .padding()
        .navigationBarHidden(true)
    }

    private func signUp() {
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
    }
}
