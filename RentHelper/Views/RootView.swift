//
//  RootView.swift
//  RentHelper
//
//  Created by Negar Pirasteh on 2026-02-09.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var auth: AuthService

    var body: some View {
        Group {
            if auth.user != nil {
                ContentView()
            } else {
                AuthContainerView()    
            }
        }
    }
}
