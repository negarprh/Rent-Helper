//
//  PaymentViewModel.swift
//  RentHelper
//
//  Created by Negar on 2026-03-31.
//
import Foundation
import Combine

@MainActor
final class PaymentViewModel: ObservableObject {
    enum Field: Hashable {
        case cardholderName
        case cardNumber
        case expiryMonth
        case expiryYear
        case cvc
    }

    enum Status {
        case idle
        case success(String)
        case failure(String)
    }

    @Published var cardholderName = ""
    @Published var cardNumber = ""
    @Published var expiryMonth = ""
    @Published var expiryYear = ""
    @Published var cvc = ""
    @Published var isLoading = false
    @Published var status: Status = .idle
    @Published var fieldErrors: [Field: String] = [:]

    let listing: Listing
    let depositAmountText: String

    private let paymentService: StripePaymentServicing

    init(
        listing: Listing,
        paymentService: StripePaymentServicing = StripePaymentService()
    ) {
        self.listing = listing
        self.paymentService = paymentService
        self.depositAmountText = StripeConfig.testDepositAmountText
    }

    func payDeposit() async {
        guard validateInputs() else {
            status = .failure("Please fix the highlighted fields and try again.")
            return
        }

        isLoading = true
        status = .idle

        let cardDetails = DepositCardDetails(
            cardholderName: cardholderName,
            cardNumber: cardNumber,
            expiryMonth: expiryMonth,
            expiryYear: expiryYear,
            cvc: cvc
        )

        do {
            let result = try await paymentService.payDeposit(for: listing, cardDetails: cardDetails)
            status = .success(result.message)
        } catch {
            status = .failure(error.localizedDescription)
        }

        isLoading = false
    }

    func fillTestCard() {
        cardholderName = "Test User"
        cardNumber = "4242424242424242"
        expiryMonth = "12"
        expiryYear = "34"
        cvc = "123"
        fieldErrors = [:]
        status = .idle
    }

    private func validateInputs() -> Bool {
        var errors: [Field: String] = [:]

        if cardholderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors[.cardholderName] = "Cardholder name is required."
        }

        let digitsOnlyCardNumber = cardNumber.filter(\.isNumber)
        if digitsOnlyCardNumber.isEmpty {
            errors[.cardNumber] = "Card number is required."
        } else if digitsOnlyCardNumber.count != 16 {
            errors[.cardNumber] = "Card number must be 16 digits."
        }

        let monthDigits = expiryMonth.filter(\.isNumber)
        if monthDigits.isEmpty {
            errors[.expiryMonth] = "Expiry month is required."
        } else if let month = Int(monthDigits), !(1...12).contains(month) {
            errors[.expiryMonth] = "Use a month between 01 and 12."
        } else if Int(monthDigits) == nil {
            errors[.expiryMonth] = "Expiry month must be numeric."
        }

        let yearDigits = expiryYear.filter(\.isNumber)
        if yearDigits.isEmpty {
            errors[.expiryYear] = "Expiry year is required."
        } else if !(yearDigits.count == 2 || yearDigits.count == 4) {
            errors[.expiryYear] = "Use YY or YYYY."
        }

        let cvcDigits = cvc.filter(\.isNumber)
        if cvcDigits.isEmpty {
            errors[.cvc] = "CVC is required."
        } else if !(3...4).contains(cvcDigits.count) {
            errors[.cvc] = "CVC must be 3 or 4 digits."
        }

        fieldErrors = errors
        return errors.isEmpty
    }
}
