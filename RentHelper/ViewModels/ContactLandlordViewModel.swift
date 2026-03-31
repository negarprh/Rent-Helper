//
//  ContactLandlordViewModel.swift
//  RentHelper
//
//  Created by Negar on 2026-03-31.
//
import Foundation
import Combine

@MainActor
final class ContactLandlordViewModel: ObservableObject {
    enum Field: Hashable {
        case fullName
        case email
        case phone
    }

    enum Status {
        case idle
        case success(String)
        case failure(String)
    }

    @Published var fullName = ""
    @Published var email = ""
    @Published var phoneNumber = ""
    @Published var message = "Hi, I’m interested in this apartment and would like more information."

    @Published var visitDate = Date().addingTimeInterval(60 * 60 * 24)
    @Published var visitTime = Date().addingTimeInterval(60 * 60 * 24)

    @Published var contactErrors: [Field: String] = [:]
    @Published var isSendingMessage = false
    @Published var isRequestingVisit = false
    @Published var messageStatus: Status = .idle
    @Published var visitStatus: Status = .idle

    func sendMessage() async {
        guard validateContactFields() else {
            messageStatus = .failure("Please complete the missing fields.")
            return
        }

        isSendingMessage = true
        messageStatus = .idle
        try? await Task.sleep(for: .seconds(1.0))
        isSendingMessage = false

        messageStatus = .success("Message sent. The landlord will contact you soon.")
    }

    func requestVisit() async {
        guard validateContactFields() else {
            visitStatus = .failure("Please complete contact details before requesting a visit.")
            return
        }

        let requestedDateTime = combineDateAndTime(date: visitDate, time: visitTime)
        guard requestedDateTime > Date() else {
            visitStatus = .failure("Please choose a future date and time.")
            return
        }

        isRequestingVisit = true
        visitStatus = .idle
        try? await Task.sleep(for: .seconds(1.0))
        isRequestingVisit = false

        let dateText = requestedDateTime.formatted(date: .abbreviated, time: .shortened)
        visitStatus = .success("Visit requested for \(dateText).")
    }

    private func validateContactFields() -> Bool {
        var errors: [Field: String] = [:]

        if fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors[.fullName] = "Full name is required."
        }

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedEmail.isEmpty {
            errors[.email] = "Email is required."
        } else if !isValidEmail(trimmedEmail) {
            errors[.email] = "Please enter a valid email."
        }

        let digits = phoneNumber.filter(\.isNumber)
        if digits.isEmpty {
            errors[.phone] = "Phone number is required."
        } else if digits.count < 10 {
            errors[.phone] = "Phone number is too short."
        }

        contactErrors = errors
        return errors.isEmpty
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^\S+@\S+\.\S+$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    private func combineDateAndTime(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let day = calendar.dateComponents([.year, .month, .day], from: date)
        let clock = calendar.dateComponents([.hour, .minute], from: time)

        var combined = DateComponents()
        combined.year = day.year
        combined.month = day.month
        combined.day = day.day
        combined.hour = clock.hour
        combined.minute = clock.minute

        return calendar.date(from: combined) ?? date
    }
}
