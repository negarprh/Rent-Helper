//
//  RentHelperApp.swift
//  RentHelper
//
//  Created by Negar Pirasteh on 2026-02-09.
//

import SwiftUI
import CoreData
import Firebase

@main
struct RentHelperApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var auth = AuthService()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
