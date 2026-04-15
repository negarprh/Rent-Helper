//
//  ContactLandlordView.swift
//  RentHelper
//
//  Created by Negar on 2026-03-31.
//
import SwiftUI

struct ContactLandlordView: View {
    let listing: Listing

    @StateObject private var viewModel = ContactLandlordViewModel()

    var body: some View {
        ZStack {
            AppPageBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    contactSection
                    visitSection
                    reserveSection
                }
                .padding()
            }
        }
        .navigationTitle("Contact Landlord")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut(duration: 0.2), value: viewModel.messageStatusText)
        .animation(.easeInOut(duration: 0.2), value: viewModel.visitStatusText)
    }

    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contact")
                .font(.title3.weight(.bold))
                .foregroundStyle(AppTheme.textPrimary)

            validatedField(
                title: "Full Name",
                placeholder: "Your full name",
                text: $viewModel.fullName,
                field: .fullName,
                keyboardType: .default
            )

            validatedField(
                title: "Email",
                placeholder: "name@email.com",
                text: $viewModel.email,
                field: .email,
                keyboardType: .emailAddress
            )

            validatedField(
                title: "Phone Number",
                placeholder: "(555) 123-4567",
                text: $viewModel.phoneNumber,
                field: .phone,
                keyboardType: .phonePad
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("Message")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)

                TextEditor(text: $viewModel.message)
                    .frame(minHeight: 110)
                    .padding(8)
                    .background(.white, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.14), lineWidth: 1)
                    )
            }

            Button {
                Task { await viewModel.sendMessage() }
            } label: {
                HStack {
                    if viewModel.isSendingMessage {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(viewModel.isSendingMessage ? "Sending..." : "Send Message")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.accent)
            .disabled(viewModel.isSendingMessage)

            if let text = viewModel.messageStatusText {
                statusLabel(text, isError: viewModel.messageStatusIsError)
            }
        }
        .padding()
        .premiumCard(cornerRadius: 18)
    }

    private var visitSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Book a Visit")
                .font(.title3.weight(.bold))
                .foregroundStyle(AppTheme.textPrimary)

            DatePicker(
                "Date",
                selection: $viewModel.visitDate,
                in: Date()...,
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)

            DatePicker(
                "Time",
                selection: $viewModel.visitTime,
                displayedComponents: [.hourAndMinute]
            )
            .datePickerStyle(.compact)

            Button {
                Task { await viewModel.requestVisit() }
            } label: {
                HStack {
                    if viewModel.isRequestingVisit {
                        ProgressView()
                    }
                    Text(viewModel.isRequestingVisit ? "Requesting..." : "Request Visit")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.bordered)
            .tint(AppTheme.accent)
            .disabled(viewModel.isRequestingVisit)

            if let text = viewModel.visitStatusText {
                statusLabel(text, isError: viewModel.visitStatusIsError)
            }
        }
        .padding()
        .premiumCard(cornerRadius: 18)
    }

    private var reserveSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ready to reserve this apartment?")
                .font(.headline.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)

            Text("Secure this unit with a deposit. This is the final step after contacting and scheduling.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)

            NavigationLink {
                PaymentView(listing: listing)
            } label: {
                Label("Pay Deposit / Reserve Apartment", systemImage: "creditcard.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.accent)
        }
        .padding()
        .premiumCard(cornerRadius: 18)
    }

    private func validatedField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        field: ContactLandlordViewModel.Field,
        keyboardType: UIKeyboardType
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)

            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(.white, in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            viewModel.contactErrors[field] == nil ? Color.gray.opacity(0.14) : AppTheme.danger,
                            lineWidth: 1
                        )
                )

            if let error = viewModel.contactErrors[field] {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(AppTheme.danger)
            }
        }
    }

    private func statusLabel(_ text: String, isError: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: isError ? "xmark.octagon.fill" : "checkmark.circle.fill")
                .foregroundStyle(isError ? AppTheme.danger : AppTheme.success)
            Text(text)
                .font(.footnote)
                .foregroundStyle(isError ? AppTheme.danger : AppTheme.success)
        }
    }
}

private extension ContactLandlordViewModel {
    var messageStatusText: String? {
        switch messageStatus {
        case .idle: return nil
        case .success(let text), .failure(let text): return text
        }
    }

    var visitStatusText: String? {
        switch visitStatus {
        case .idle: return nil
        case .success(let text), .failure(let text): return text
        }
    }

    var messageStatusIsError: Bool {
        if case .failure = messageStatus { return true }
        return false
    }

    var visitStatusIsError: Bool {
        if case .failure = visitStatus { return true }
        return false
    }
}
