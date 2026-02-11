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
}

