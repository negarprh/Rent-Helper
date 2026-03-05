//
//  ProfileView.swift
//  RentHelper
//
//  Created by Naomi on 2026-03-02.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {

    @EnvironmentObject var auth: AuthService

    var body: some View {

        NavigationStack {

            VStack(spacing: 20) {

                Spacer()

                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 110, height: 110)
                        .shadow(color: .black.opacity(0.15), radius: 8)

                    Image(systemName: "person.fill")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundColor(.gray)
                }

                Text("Profile")
                    .font(.title2)
                    .bold()

                if let email = auth.user?.email, !email.isEmpty {
                    Text(email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                } else {
                    Text("Signed in")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Button {
                    auth.signOut { _ in }
                } label: {
                    HStack {
                        Image(systemName: "arrow.right.square")
                        Text("Logout")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(.gray)
                .clipShape(Capsule())
                .padding(.horizontal, 24)
                .padding(.top, 10)

                Spacer()
                Spacer()
            }
            .padding()
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}
