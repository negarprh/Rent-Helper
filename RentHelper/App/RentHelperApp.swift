//
//  RentHelperApp.swift
//  RentHelper
//
//  Created by Negar Pirasteh on 2026-02-09.
//
import SwiftUI
import CoreData
import Firebase
import StripePaymentSheet
import UIKit

@main
struct RentHelperApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var auth = AuthService()

    init() {
        FirebaseApp.configure()
        configureNavigationBarAppearance()

        StripeAPI.defaultPublishableKey = StripeConfig.publishableKey
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }

    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(
            red: 0.95,
            green: 0.98,
            blue: 1.0,
            alpha: 0.96
        )

        let titleColor = UIColor.black

        appearance.titleTextAttributes = [.foregroundColor: titleColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: titleColor]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(
            red: 0.06,
            green: 0.40,
            blue: 0.66,
            alpha: 1.0
        )
    }
}
