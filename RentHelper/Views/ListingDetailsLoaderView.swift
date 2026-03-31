//
//  ListingDetailsLoaderView.swift
//  RentHelper
//
//  Created by Negar on 2026-03-31.
//
import SwiftUI

struct ListingDetailsLoaderView: View {
    let listingId: String

    @State private var listing: Listing?
    @State private var errorMessage: String?
    @State private var isLoading = false

    private let listingService = ListingService()

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading listing...")
            } else if let listing {
                ListingDetailsView(listing: listing)
            } else if let errorMessage {
                VStack(spacing: 12) {
                    Text(errorMessage)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task { await loadListing() }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.accent)
                }
                .padding()
            } else {
                ContentUnavailableView("Listing not found", systemImage: "exclamationmark.triangle")
            }
        }
        .task {
            await loadListing()
        }
        .navigationTitle("Listing")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func loadListing() async {
        isLoading = true
        errorMessage = nil

        do {
            listing = try await listingService.fetchListing(by: listingId)
            if listing == nil {
                errorMessage = "This listing is no longer available."
            }
        } catch {
            errorMessage = "Could not load listing. Please try again."
        }

        isLoading = false
    }
}
