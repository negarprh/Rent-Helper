//
//  ContentView.swift
//  RentHelper
//
//  Created by Negar Pirasteh on 2026-02-09.
//  Edited by Naomi on 2026-03-02 
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {

    @EnvironmentObject var auth: AuthService
    @State private var selectedTab: Int = 0

    var body: some View {

        TabView(selection: $selectedTab) {

            Tab("Listings", systemImage: "house", value: 0) {
                ListingsView()
            }

            Tab("Map", systemImage: "map", value: 1) {
                ListingsMapView(selectedTab: $selectedTab)
            }

            Tab("Favorites", systemImage: "heart", value: 2) {
                FavoritesView(userId: auth.user?.uid ?? "")
            }

            Tab("Profile", systemImage: "person", value: 3) {
                ProfileView()
            }
        }
    }
}
