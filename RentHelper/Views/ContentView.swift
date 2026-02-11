//
//  ContentView.swift
//  RentHelper
//
//  Created by Negar Pirasteh on 2026-02-09.
//
import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var auth: AuthService
    
//    @Environment(\.managedObjectContext) private var viewContext
//
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \FavoriteListing.savedAt, ascending: false)],
//        animation: .default
//    )
//    private var favorites: FetchedResults<FavoriteListing>

    var body: some View {
            TabView {
                Tab("Listings", systemImage: "house") {
                    ListingsView()
                }

                Tab("Favorites", systemImage: "heart") {
                    FavoritesView(userId: auth.user?.uid ?? "")
                }

                Tab("Profile", systemImage: "person") {
                    VStack(spacing: 16) {
                        Text("Profile")
                        Button("Logout") {
                            auth.signOut { _ in }
                        }
                    }
                }
            }
        }
}
