//
//  ListingService.swift
//  RentHelper
//
//  Created by Negar Pirasteh on 2026-02-09.
//
import FirebaseFirestore

final class ListingService {
    private let db = Firestore.firestore()
    private var listingsListener: ListenerRegistration?

    func fetchListings() async throws -> [Listing] {
        let snapshot = try await db.collection("listings").getDocuments()
        return decodeListings(from: snapshot)
    }

    func fetchListing(by id: String) async throws -> Listing? {
        let document = try await db.collection("listings").document(id).getDocument()
        guard let data = document.data() else { return nil }
        return mapListingManually(documentId: document.documentID, data: data)
    }

    func startListingsListener(
        onUpdate: @escaping (Result<[Listing], Error>) -> Void
    ) {
        stopListingsListener()

        listingsListener = db.collection("listings").addSnapshotListener { [weak self] snapshot, error in
            if let error {
                onUpdate(.failure(error))
                return
            }

            guard let snapshot else {
                onUpdate(.success([]))
                return
            }

            guard let self else { return }
            let listings = self.decodeListings(from: snapshot)
            onUpdate(.success(listings))
        }
    }

    func stopListingsListener() {
        listingsListener?.remove()
        listingsListener = nil
    }

    deinit {
        stopListingsListener()
    }

    private func decodeListings(from snapshot: QuerySnapshot) -> [Listing] {
        snapshot.documents.compactMap { decodeListing(from: $0) }
    }

    private func decodeListing(from document: QueryDocumentSnapshot) -> Listing? {
        let data = document.data()
        let fieldIssues = inferFieldIssues(from: data)
        if !fieldIssues.isEmpty {
            logFieldIssues(documentId: document.documentID, data: data, issues: fieldIssues)
        }
        return mapListingManually(documentId: document.documentID, data: data)
    }

    private func mapListingManually(documentId: String, data: [String: Any]) -> Listing? {
        let title = asString(data["title"]) ?? "Untitled"
        let price = asDouble(data["price"]) ?? 0
        let address = asString(data["address"]) ?? "Address unavailable"
        let city = asString(data["city"]) ?? "Unknown city"
        let lat = asDouble(data["lat"]) ?? asDouble(data["latitude"]) ?? 0
        let long = asDouble(data["long"]) ?? asDouble(data["lng"]) ?? asDouble(data["longitude"]) ?? 0
        let description = asString(data["description"]) ?? asString(data["details"]) ?? "No description available."
        let imageUrl = asString(data["imageUrl"]) ?? asString(data["imageURL"]) ?? asString(data["photoUrl"])

        return Listing(
            id: documentId,
            title: title,
            price: price,
            address: address,
            city: city,
            lat: lat,
            long: long,
            description: description,
            imageUrl: imageUrl
        )
    }

    private func asString(_ value: Any?) -> String? {
        switch value {
        case let string as String:
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        case let number as NSNumber:
            return number.stringValue
        default:
            return nil
        }
    }

    private func asDouble(_ value: Any?) -> Double? {
        switch value {
        case let number as NSNumber:
            return number.doubleValue
        case let string as String:
            return Double(string.trimmingCharacters(in: .whitespacesAndNewlines))
        default:
            return nil
        }
    }

    private func logFieldIssues(documentId: String, data: [String: Any], issues: [String]) {
        print("[ListingService] Data format issue in document '\(documentId)'")
        print("[ListingService] Raw Firestore data: \(data)")
        issues.forEach { issue in
            print("[ListingService] Field issue: \(issue)")
        }
    }

    private func inferFieldIssues(from data: [String: Any]) -> [String] {
        var issues: [String] = []

        if asString(data["title"]) == nil { issues.append("title missing/invalid (expected String)") }
        if asDouble(data["price"]) == nil { issues.append("price missing/invalid (expected Number or numeric String)") }
        if asString(data["address"]) == nil { issues.append("address missing/invalid (expected String)") }
        if asString(data["city"]) == nil { issues.append("city missing/invalid (expected String)") }
        if asDouble(data["lat"]) == nil && asDouble(data["latitude"]) == nil {
            issues.append("lat missing/invalid (expected Number or numeric String)")
        }
        if asDouble(data["long"]) == nil && asDouble(data["lng"]) == nil && asDouble(data["longitude"]) == nil {
            issues.append("long missing/invalid (expected Number or numeric String)")
        }
        if asString(data["description"]) == nil && asString(data["details"]) == nil {
            issues.append("description missing/invalid (expected String)")
        }

        return issues
    }
}
