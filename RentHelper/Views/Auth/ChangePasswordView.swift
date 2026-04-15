//
//  ChangePasswordView.swift
//  RentHelper
//
//  Created by Betty Dang on 2026-03-31.
//
import SwiftUI
import FirebaseAuth


struct ChangePasswordView: View {
    
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var message = ""
    @State private var showAlert: Bool = false
    @FocusState private var focusedField: Field?

    enum Field {
        case currentPassword
        case newPassword
        case confirmPassword
    }

    var body: some View {
        ZStack {
            AppPageBackground()

            VStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Security")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Update your password to keep your account secure.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 12) {
                    SecureField("Current Password", text: $currentPassword)
                        .focused($focusedField, equals: .currentPassword)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(.white, in: RoundedRectangle(cornerRadius: 12))

                    SecureField("New Password", text: $newPassword)
                        .focused($focusedField, equals: .newPassword)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(.white, in: RoundedRectangle(cornerRadius: 12))

                    SecureField("Confirm Password", text: $confirmPassword)
                        .focused($focusedField, equals: .confirmPassword)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(.white, in: RoundedRectangle(cornerRadius: 12))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )

                Button {
                    focusedField = nil
                    changePassword()
                } label: {
                    HStack {
                        Image(systemName: "lock.fill")
                        Text("Update Password")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty)
            }
            .padding(20)
            .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 22))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.white.opacity(0.9), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 12, y: 6)
            .padding()
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
        .alert(message, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        }
    }
    func changePassword() {
        guard let user = Auth.auth().currentUser,
              let email = user.email else { return }
        
        if newPassword != confirmPassword {
            message = "Passwords do not match"
            showAlert = true
            return
        }
        
        let credential = EmailAuthProvider.credential(
            withEmail: email,
            password: currentPassword
        )
        
        user.reauthenticate(with: credential) { _, error in
            if error != nil {
                message = "Current password incorrect"
                showAlert = true
                return
            }
            
            user.updatePassword(to: newPassword) { error in
                if let error = error {
                    message = error.localizedDescription
                } else {
                    message = "Password updated successfully"
                }
                showAlert = true
            }
        }
    }
}
