//
//  ListingHelper.swift
//  RentHelper
//
//  Created by Betty Dang on 2026-02-10.
//

import Foundation

extension Listing {
    init(from favorite: FavoriteListing) {
        self.init(
            id: favorite.listingId ?? UUID().uuidString,
            title: favorite.title ?? "Untitled",
            price: favorite.price,
            address: favorite.address ?? "",
            city: favorite.city ?? "",
            lat: favorite.lat,
            long: favorite.long,
            description: "Saved listing",
            imageUrl: favorite.imageUrl ?? ""
        )
    }
}
