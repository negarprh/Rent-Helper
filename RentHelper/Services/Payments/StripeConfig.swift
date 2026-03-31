//
//  StripeConfig.swift
//  RentHelper
//
//  Created by Negar Pirasteh on 2026-03-31.
//
import Foundation

enum StripeConfig {
    static let publishableKey = "pk_test"
    static let secretKey = ""
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
        secretKey.contains("")
    }

    static var isStripeConfiguredForDemo: Bool {
        !publishableKey.isEmpty
    }
}
