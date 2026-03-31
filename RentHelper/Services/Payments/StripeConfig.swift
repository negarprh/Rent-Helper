//
//  StripeConfig.swift
//  RentHelper
//
//  Created by Negar Pirasteh on 2026-03-31.
//
import Foundation

enum StripeConfig {
    static let publishableKey = "pk_test_51TGrtsFgPxVuWqVYH3GIKR7qWKCJtnNJ9caqgIsE3ADTHQKeqJ6nPmZrc7BvrnuuXsdblLFg5V2Ejh8Z9MABwAKN006Uy4SiNV"
    static let secretKey = "sk_test_backend"
    static let currencyCode = "CAD"
    static let countryCode = "CA"
    static let supportEmail = "support@renthelper.app"

    static let testDepositAmountInCents = 50_00

    static var testDepositAmountText: String {
        let amount = Double(testDepositAmountInCents) / 100
        return amount.formatted(.currency(code: currencyCode))
    }

    static var isUsingPlaceholderPublishableKey: Bool {
        publishableKey.contains("publishable_key")
    }

    static var isUsingPlaceholderSecretKey: Bool {
        secretKey.contains("sk_test_backend")
    }

    static var isStripeConfiguredForDemo: Bool {
        !publishableKey.isEmpty
    }
}
