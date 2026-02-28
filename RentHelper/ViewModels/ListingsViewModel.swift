//
//  ListingsViewModel.swift
//  RentHelper
//
//  Created by Naomi on 2026-02-09.
//

import Foundation
import Combine

@MainActor
final class ListingsViewModel: ObservableObject {

    @Published var listings: [Listing] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let service = ListingService()

    func loadListings() async {
        isLoading = true
        errorMessage = nil

        do {
            listings = try await service.fetchListings()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func startRealtimeUpdates() {
        errorMessage = nil
        if listings.isEmpty {
            isLoading = true
        }

        service.startListingsListener { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self else { return }

                switch result {
                case .success(let listings):
                    self.listings = listings
                    self.errorMessage = nil
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }

                self.isLoading = false
            }
        }
    }

    func stopRealtimeUpdates() {
        service.stopListingsListener()
    }

    func retry() async {
        await loadListings()
        startRealtimeUpdates()
    }
}
