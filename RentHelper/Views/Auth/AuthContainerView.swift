//
//  AuthContainerView.swift
//  RentHelper
//
//  Created by Negar Pirasteh on 2026-02-09.
//

import SwiftUI

struct AuthContainerView: View {
    @State private var showSignup = false

    var body: some View {
        NavigationStack {
            if showSignup {
                SignupView(onSwitchToLogin: { showSignup = false })
            } else {
                LoginView(onSwitchToSignup: { showSignup = true })
            }
        }
    }
}
