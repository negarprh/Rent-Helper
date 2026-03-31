//
//  StripePaymentService.swift
//  RentHelper
//
//  Created by Negar Pirasteh on 2026-03-31.
//
import Foundation
import StripePaymentSheet

struct DepositCardDetails {
    let cardholderName: String
    let cardNumber: String
    let expiryMonth: String
    let expiryYear: String
    let cvc: String
}

struct DepositPaymentResult {
    let message: String
}

enum StripePaymentError: LocalizedError {
    case invalidCardholderName
    case invalidCardNumber
    case invalidExpiryMonth
    case invalidExpiryYear
    case invalidCVC
    case missingPublishableKey

    var errorDescription: String? {
        switch self {
        case .invalidCardholderName:
            return "Enter the cardholder name."
        case .invalidCardNumber:
            return "Enter a valid test card number."
        case .invalidExpiryMonth:
            return "Enter an expiry month between 01 and 12."
        case .invalidExpiryYear:
            return "Enter a valid expiry year."
        case .invalidCVC:
            return "Enter a valid CVC."
        case .missingPublishableKey:
            return "Add your Stripe test publishable key to StripeConfig before connecting the real SDK flow."
        }
    }
}

protocol StripePaymentServicing {
    func payDeposit(for listing: Listing, cardDetails: DepositCardDetails) async throws -> DepositPaymentResult
}

final class StripePaymentService: StripePaymentServicing {
    func payDeposit(for listing: Listing, cardDetails: DepositCardDetails) async throws -> DepositPaymentResult {
        try validate(cardDetails)

        guard !StripeConfig.publishableKey.isEmpty else {
            throw StripePaymentError.missingPublishableKey
        }

        StripeAPI.defaultPublishableKey = StripeConfig.publishableKey

        try await Task.sleep(for: .seconds(1.2))

        let message: String
        if StripeConfig.isUsingPlaceholderPublishableKey {
            message = "Demo deposit submitted for \(listing.title). Replace the publishable key and add a backend PaymentIntent later to make a real Stripe payment."
        } else {
            message = "Test deposit flow completed for \(listing.title). Add a backend PaymentIntent next to confirm the charge for real."
        }

        return DepositPaymentResult(message: message)
    }

    private func validate(_ cardDetails: DepositCardDetails) throws {
        let trimmedName = cardDetails.cardholderName.trimmingCharacters(in: .whitespacesAndNewlines)
        let sanitizedCardNumber = cardDetails.cardNumber.filter(\.isNumber)
        let sanitizedMonth = cardDetails.expiryMonth.filter(\.isNumber)
        let sanitizedYear = cardDetails.expiryYear.filter(\.isNumber)
        let sanitizedCVC = cardDetails.cvc.filter(\.isNumber)

        guard !trimmedName.isEmpty else {
            throw StripePaymentError.invalidCardholderName
        }

        guard sanitizedCardNumber.count == 16 else {
            throw StripePaymentError.invalidCardNumber
        }

        guard let month = Int(sanitizedMonth), (1...12).contains(month) else {
            throw StripePaymentError.invalidExpiryMonth
        }

        guard sanitizedYear.count == 2 || sanitizedYear.count == 4 else {
            throw StripePaymentError.invalidExpiryYear
        }

        guard (3...4).contains(sanitizedCVC.count) else {
            throw StripePaymentError.invalidCVC
        }
    }
}
