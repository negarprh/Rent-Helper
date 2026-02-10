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
}

