//
//  ProfileView.swift
//  RentHelper
//
//  Created by Betty on 2026-03-02.
//
import SwiftUI
import FirebaseAuth
import CoreData

struct ProfileView: View {

    @EnvironmentObject var auth: AuthService
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DepositedListing.paidAt, ascending: false)],
        animation: .default
    )
    private var depositedListings: FetchedResults<DepositedListing>

    private var userDeposits: [DepositedListing] {
        let userId = auth.user?.uid ?? ""
        return depositedListings.filter { $0.userId == userId }
    }

    var body: some View {

        NavigationStack {
            ZStack {
                AppPageBackground()

                ScrollView {
                    VStack(spacing: 20) {

                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 110, height: 110)
                            .shadow(color: .black.opacity(0.15), radius: 8)

                        Image(systemName: "person.fill")
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundColor(.gray)
                    }

                    Text("Profile")
                        .font(.title2)
                        .bold()

                    if let email = auth.user?.email, !email.isEmpty {
                        Text(email)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    } else {
                        Text("Signed in")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    NavigationLink{
                        ChangePasswordView()
                    } label: {
                        HStack {
                            Image(systemName: "lock")
                            Text("Change Password")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                    .tint(AppTheme.accent)
                    .clipShape(Capsule())
                    .padding(.horizontal, 24)

                    Button {
                        auth.signOut { _ in }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.right.square")
                            Text("Logout")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.accent)
                    .clipShape(Capsule())
                    .padding(.horizontal, 24)
                    .padding(.top, 10)

                    statsStrip

                    depositedListingsSection
                }
                    .padding()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }

    @ViewBuilder
    private var depositedListingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Deposited Listings")
                .font(.title3)
                .bold()
                .padding(.horizontal, 4)

            if userDeposits.isEmpty {
                Text("No deposit payments yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            } else {
                ForEach(userDeposits, id: \.objectID) { deposit in
                    if let listingId = deposit.listingId, !listingId.isEmpty {
                        NavigationLink {
                            ListingDetailsLoaderView(listingId: listingId)
                        } label: {
                            depositCard(deposit)
                        }
                        .buttonStyle(.plain)
                    } else {
                        depositCard(deposit)
                    }
                }
            }
        }
        .padding(.top, 6)
        .padding(.horizontal, 12)
        .padding(.bottom, 20)
    }

    private var statsStrip: some View {
        HStack(spacing: 10) {
            statPill(
                title: "Deposits",
                value: "\(userDeposits.count)",
                icon: "creditcard.fill"
            )

            let total = userDeposits.reduce(0.0) { $0 + $1.depositAmount }
            statPill(
                title: "Total",
                value: total.formatted(.currency(code: "CAD")),
                icon: "dollarsign.circle.fill"
            )
        }
        .padding(.horizontal, 12)
    }

    private func statPill(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(AppTheme.accent)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .premiumCard(cornerRadius: 14)
    }

    private func depositCard(_ deposit: DepositedListing) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(deposit.title ?? "Listing")
                .font(.headline)

            Text("\(deposit.address ?? ""), \(deposit.city ?? "")")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Deposit: \((deposit.depositAmount).formatted(.currency(code: "CAD")))")
                .font(.subheadline)

            Text("Status: \(deposit.status ?? "Unknown")")
                .font(.subheadline)
                .foregroundStyle(AppTheme.success)

            if let paidAt = deposit.paidAt {
                Text("Paid on: \(paidAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumCard(cornerRadius: 14)
    }
}
