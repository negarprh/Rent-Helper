//
//  ListingModel.swift
//  RentHelper
//
//  Created by Betty Dang on 2026-02-09.
//

import Foundation

struct Listing: Identifiable {
    let id: String
    let title: String
    let price: Double
    let address: String
    let city: String
    let lat: Double
    let long: Double
    let description: String
    let imageUrl: String?

    init(
        id: String,
        title: String,
        price: Double,
        address: String,
        city: String,
        lat: Double,
        long: Double,
        description: String,
        imageUrl: String?
    ) {
        self.id = id
        self.title = title
        self.price = price
        self.address = address
        self.city = city
        self.lat = lat
        self.long = long
        self.description = description
        self.imageUrl = imageUrl
    }
}
