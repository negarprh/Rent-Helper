//
//  ListingService.swift
//  RentHelper
//
//  Created by Negar Pirasteh on 2026-02-09.
//

import FirebaseFirestore

final class ListingService {
    private let db = Firestore.firestore()

    func fetchListings() {
        db.collection("listings").getDocuments { snapshot, error in
            if let error = error {
                print("Firestore error:", error.localizedDescription)
                return
            }

            print("Listings count:", snapshot?.documents.count ?? 0)
        }
    }
}
