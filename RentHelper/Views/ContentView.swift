//
//  ContentView.swift
//  RentHelper
//
//  Created by Negar Pirasteh on 2026-02-09.
//
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: AuthService

    var body: some View {
        TabView {
            Text("Listings")
                .tabItem { Label("Listings", systemImage: "house") }

            Text("Favorites")
                .tabItem { Label("Favorites", systemImage: "heart") }

            VStack(spacing: 16) {
                Text("Profile")
                Button("Logout") {
                    auth.signOut { _ in }
                }
            }
            .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}
