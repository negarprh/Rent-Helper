//
//  ListingService.swift
//  RentHelper
//
//  Created by Negar Pirasteh on 2026-02-09.
//
import FirebaseFirestore
//
//final class ListingService {
//    private let db = Firestore.firestore()
//
//    func fetchListings() async throws -> [Listing] {
//        let snapshot = try await db.collection("listings").getDocuments()
//
//        return snapshot.documents.map { doc in
//            let data = doc.data()
//
//            let title = data["title"] as? String ?? ""
//            let price = data["price"] as? Double ?? 0
//            let address = data["address"] as? String ?? ""
//            let city = data["city"] as? String ?? ""
//            let lat = data["lat"] as? Double ?? 0
//            let long = data["long"] as? Double ?? 0
//            let description = data["description"] as? String ?? ""
//            let imageUrl = data["imageUrl"] as? String
//
//            return Listing(
//                id: doc.documentID,
//                title: title,
//                price: price,
//                address: address,
//                city: city,
//                lat: lat,
//                long: long,
//                description: description,
//                imageUrl: imageUrl
//            )
//        }
//    }
//}
final class ListingService {

    func fetchListings() async throws -> [Listing] {
        return [
            Listing(
                id: "1",
                title: "Modern Studio Downtown",
                price: 1200,
                address: "123 Main St",
                city: "Montreal",
                lat: 45.5017,
                long: -73.5673,
                description: "Bright studio near metro, fully furnished.",
                imageUrl: nil
            ),
            Listing(
                id: "2",
                title: "2 Bedroom Apartment",
                price: 1800,
                address: "456 Queen St",
                city: "Montreal",
                lat: 45.5088,
                long: -73.5617,
                description: "Spacious apartment, pet friendly.",
                imageUrl: nil
            ),
            Listing(
                id: "3",
                title: "Cozy Room for Rent",
                price: 700,
                address: "789 Sherbrooke St",
                city: "Montreal",
                lat: 45.5030,
                long: -73.5690,
                description: "Private room in shared apartment.",
                imageUrl: nil
            )
        ]
    }
}

