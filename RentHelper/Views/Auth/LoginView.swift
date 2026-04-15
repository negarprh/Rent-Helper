//
//  LoginView.swift
//  RentHelper
//
//  Created by Negar Pirasteh on 2026-02-09.
//
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthService

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var showForgotPasswordSheet = false
    @State private var resetEmail = ""
    @State private var resetStatusMessage: String?
    @State private var isResetLoading = false

    let onSwitchToSignup: () -> Void
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
                    Image(systemName: "building.2.crop.circle.fill")
                        .font(.system(size: 54))
                        .foregroundStyle(AppTheme.accent)

                    Text("RentHelper")
                        .font(.system(size: 36, weight: .bold, design: .rounded))

                    Text("Sign in to manage listings, favorites, and deposits")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
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

                    SecureField("Password", text: $password)
                        .focused($focusedField, equals: .password)
                        .textContentType(.password)
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
                    signIn()
                } label: {
                    HStack {
                        Spacer()
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(isLoading ? "Signing in..." : "Sign In")
                            .bold()
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .background(isLoading ? Color.gray.opacity(0.4) : AppTheme.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isLoading)

                HStack {
                    Spacer()
                    Button {
                        focusedField = nil
                        resetEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
                        resetStatusMessage = nil
                        showForgotPasswordSheet = true
                    } label: {
                        Text("Forgot password?")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(AppTheme.accent)
                    }
                    .buttonStyle(.plain)
                }

                Divider()

                Button {
                    onSwitchToSignup()
                } label: {
                    Text("Don’t have an account? Sign up")
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
        .sheet(isPresented: $showForgotPasswordSheet) {
            forgotPasswordSheet
                .presentationDetents([.medium])
        }
    }

    private func signIn() {
        errorMessage = nil

        let e = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !e.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password are required."
            return
        }

        isLoading = true
        auth.signIn(email: e, password: password) { err in
            isLoading = false
            errorMessage = err
        }
    }

    private var forgotPasswordSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                Text("Reset your password")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("Enter your account email and we will send a password reset link.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)

                TextField("Email", text: $resetEmail)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(.white, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                    )

                if let resetStatusMessage {
                    Text(resetStatusMessage)
                        .font(.footnote)
                        .foregroundStyle(resetStatusMessage.contains("sent") ? AppTheme.success : AppTheme.danger)
                }

                Button {
                    sendPasswordReset()
                } label: {
                    HStack {
                        if isResetLoading {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(isResetLoading ? "Sending..." : "Send Reset Link")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
                .disabled(isResetLoading)

                Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle("Forgot Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showForgotPasswordSheet = false
                    }
                }
            }
        }
    }

    private func sendPasswordReset() {
        let trimmedEmail = resetEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            resetStatusMessage = "Please enter your email address."
            return
        }

        isResetLoading = true
        resetStatusMessage = nil
        auth.sendPasswordReset(email: trimmedEmail) { err in
            isResetLoading = false
            if let err {
                resetStatusMessage = err
            } else {
                resetStatusMessage = "Reset link sent. Check your email."
            }
        }
    }
}
