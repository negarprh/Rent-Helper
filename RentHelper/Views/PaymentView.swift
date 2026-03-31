//
//  PaymentView.swift
//  RentHelper
//
//  Created by Negar on 2026-03-31.
//
import SwiftUI
import CoreData
import FirebaseAuth

struct PaymentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var auth: AuthService

    @StateObject private var viewModel: PaymentViewModel

    init(listing: Listing) {
        _viewModel = StateObject(wrappedValue: PaymentViewModel(listing: listing))
    }

    var body: some View {
        ZStack {
            AppPageBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    summarySection
                    paymentFormSection
                    statusSection
                }
                .padding()
            }
        }
        .navigationTitle("Pay Deposit")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.listing.title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)

            Text("\(viewModel.listing.address), \(viewModel.listing.city)")
                .foregroundStyle(AppTheme.textSecondary)

            Label("Test deposit amount: \(viewModel.depositAmountText)", systemImage: "dollarsign.circle")
                .font(.headline)
                .foregroundStyle(AppTheme.accent)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumCard(cornerRadius: 18)
    }

    private var paymentFormSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Test Card Details")
                .font(.headline.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)

            Group {
                validatedField(
                    title: "Cardholder Name",
                    placeholder: "Name on card",
                    text: $viewModel.cardholderName,
                    field: .cardholderName
                )

                validatedField(
                    title: "Card Number",
                    placeholder: "4242 4242 4242 4242",
                    text: $viewModel.cardNumber,
                    field: .cardNumber,
                    keyboardType: .numberPad
                )

                HStack {
                    validatedField(
                        title: "Expiry Month",
                        placeholder: "MM",
                        text: $viewModel.expiryMonth,
                        field: .expiryMonth,
                        keyboardType: .numberPad
                    )

                    validatedField(
                        title: "Expiry Year",
                        placeholder: "YY or YYYY",
                        text: $viewModel.expiryYear,
                        field: .expiryYear,
                        keyboardType: .numberPad
                    )

                    validatedField(
                        title: "CVC",
                        placeholder: "123",
                        text: $viewModel.cvc,
                        field: .cvc,
                        keyboardType: .numberPad,
                        isSecure: true
                    )
                }
            }

            Text("Use Stripe test card 4242 4242 4242 4242 for demo purposes.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Button("Fill Test Card") {
                viewModel.fillTestCard()
            }
            .buttonStyle(.bordered)
            .tint(AppTheme.accent)

            Button {
                Task {
                    await viewModel.payDeposit()
                    await handlePostPaymentFlow()
                }
            } label: {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    }

                    Text(viewModel.isLoading ? "Processing..." : "Pay Deposit")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.accent)
            .disabled(viewModel.isLoading)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumCard(cornerRadius: 18)
    }

    @ViewBuilder
    private var statusSection: some View {
        switch viewModel.status {
        case .idle:
            EmptyView()
        case .success(let message):
            messageCard(message: message, color: AppTheme.success, icon: "checkmark.circle.fill")
        case .failure(let message):
            messageCard(message: message, color: AppTheme.danger, icon: "xmark.octagon.fill")
        }
    }

    private func messageCard(message: String, color: Color, icon: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)

            Text(message)
                .foregroundStyle(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
    }

    private func validatedField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        field: PaymentViewModel.Field,
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Group {
                if isSecure {
                    SecureField(placeholder, text: text)
                } else {
                    TextField(placeholder, text: text)
                }
            }
            .keyboardType(keyboardType)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.white, in: RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        viewModel.fieldErrors[field] == nil ? Color.gray.opacity(0.18) : AppTheme.danger,
                        lineWidth: 1
                    )
            )

            if let error = viewModel.fieldErrors[field] {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(AppTheme.danger)
            }
        }
    }

    private func handlePostPaymentFlow() async {
        guard case .success = viewModel.status else { return }
        saveDepositedListing()

        try? await Task.sleep(for: .seconds(0.9))
        dismiss()
    }

    private func saveDepositedListing() {
        guard let userId = auth.user?.uid, !userId.isEmpty else { return }

        let request: NSFetchRequest<DepositedListing> = DepositedListing.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(
            format: "userId == %@ AND listingId == %@",
            userId,
            viewModel.listing.id
        )

        do {
            let existing = try context.fetch(request).first
            let deposit = existing ?? DepositedListing(context: context)

            if existing == nil {
                deposit.depositId = UUID().uuidString
                deposit.userId = userId
                deposit.listingId = viewModel.listing.id
            }

            deposit.title = viewModel.listing.title
            deposit.address = viewModel.listing.address
            deposit.city = viewModel.listing.city
            deposit.imageUrl = viewModel.listing.imageUrl
            deposit.depositAmount = Double(StripeConfig.testDepositAmountInCents) / 100
            deposit.status = "Paid (Test)"
            deposit.paidAt = Date()

            try context.save()
        } catch {
            print("Save deposited listing error:", error)
        }
    }
}
