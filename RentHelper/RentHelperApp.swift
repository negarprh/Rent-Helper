//
//  RentHelperApp.swift
//  RentHelper
//
//  Created by Negar Pirasteh on 2026-02-09.
//

import SwiftUI
import CoreData

@main
struct RentHelperApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
