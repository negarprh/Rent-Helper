//
//  AppTheme.swift
//  RentHelper
//
//  Created by Negar on 2026-03-31.
//
import SwiftUI

enum AppTheme {
    static let accent = Color(red: 0.06, green: 0.40, blue: 0.66)
    static let accentSoft = Color(red: 0.82, green: 0.92, blue: 0.99)
    static let textPrimary = Color(red: 0.10, green: 0.18, blue: 0.28)
    static let textSecondary = Color(red: 0.35, green: 0.43, blue: 0.53)
    static let success = Color(red: 0.11, green: 0.56, blue: 0.29)
    static let danger = Color(red: 0.78, green: 0.20, blue: 0.18)
    static let cardBackground = Color.white.opacity(0.78)

    static let pageGradient = LinearGradient(
        colors: [
            Color(red: 0.95, green: 0.98, blue: 1.0),
            Color(red: 0.90, green: 0.95, blue: 0.99)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct PremiumCardModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.88), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 12, y: 6)
    }
}

extension View {
    func premiumCard(cornerRadius: CGFloat = 18) -> some View {
        modifier(PremiumCardModifier(cornerRadius: cornerRadius))
    }
}

struct AppPageBackground: View {
    var body: some View {
        ZStack {
            AppTheme.pageGradient
                .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.45))
                .frame(width: 280, height: 280)
                .blur(radius: 2)
                .offset(x: -140, y: -270)

            Circle()
                .fill(AppTheme.accentSoft.opacity(0.7))
                .frame(width: 330, height: 330)
                .blur(radius: 6)
                .offset(x: 180, y: 320)
        }
        .ignoresSafeArea()
    }
}
