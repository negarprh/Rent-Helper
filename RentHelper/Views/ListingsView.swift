//
//  ListingsView.swift
//  RentHelper
//
//  Created by Naomi on 2026-02-09.
//

import SwiftUI

struct ListingsView: View {
    @StateObject private var vm = ListingsViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView("Loading listings...")
                } else if let msg = vm.errorMessage {
                    VStack(spacing: 12) {
                        Text("Error: \(msg)")
                        Button("Retry") {
                            Task { await vm.loadListings() }
                        }
                    }
                } else {
                    List(vm.listings) { listing in
                        NavigationLink {
                            ListingDetailsView(listing: listing)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(listing.title).font(.headline)
                                Text("$\(listing.price, specifier: "%.0f")").font(.subheadline)
                                Text(listing.address).font(.caption)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Listings")
            .task {
                await vm.loadListings()
            }
        }
    }
}
