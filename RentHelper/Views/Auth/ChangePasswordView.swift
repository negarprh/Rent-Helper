//
//  ChangePasswordView.swift
//  RentHelper
//
//  Created by Betty Dang on 2026-03-29.
//

import SwiftUI
import FirebaseAuth


struct ChangePasswordView: View {
    
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var message = ""
    @State private var showAlert: Bool = false

    var body: some View {
        VStack {
            
            Form {
                Section(header: Text("Change Password")) {
                    SecureField("Current Password", text: $currentPassword)
                    SecureField("New Password", text: $newPassword)
                    SecureField("Confirm Password", text: $confirmPassword)
                }
            }
            
            Button {
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
            .clipShape(Capsule())
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            .disabled(currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty)
        }
        .navigationTitle("Change Password")
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

