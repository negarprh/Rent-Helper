//
//  ListingsViewModel.swift
//  RentHelper
//
//  Created by Naomi on 2026-02-09.
//
import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class ListingsViewModel: ObservableObject {

    @Published var listings: [Listing] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let service = ListingService()

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

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
        if listings.isEmpty { isLoading = true }

        listener?.remove()
        listener = db.collection("listings").addSnapshotListener { [weak self] snapshot, error in
            guard let self else { return }

            Task { @MainActor in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    return
                }

                let docs = snapshot?.documents ?? []
                self.listings = docs.map { doc in
                    let data = doc.data()

                    let priceAny = data["price"]
                    let price: Double
                    if let p = priceAny as? Double { price = p }
                    else if let p = priceAny as? Int { price = Double(p) }
                    else { price = 0 }

                    return Listing(
                        id: doc.documentID,
                        title: data["title"] as? String ?? "",
                        price: price,
                        address: data["address"] as? String ?? "",
                        city: data["city"] as? String ?? "",
                        lat: data["lat"] as? Double ?? 0,
                        long: data["long"] as? Double ?? 0,
                        description: data["description"] as? String ?? "",
                        imageUrl: data["imageUrl"] as? String
                    )
                }

                self.errorMessage = nil
                self.isLoading = false
            }
        }
    }

    func stopRealtimeUpdates() {
        listener?.remove()
        listener = nil
    }

    func retry() async {
        await loadListings()
        startRealtimeUpdates()
    }
}
