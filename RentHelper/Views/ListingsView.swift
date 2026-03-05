//
//  ListingsView.swift
//  RentHelper
//
//  Created by Naomi on 2026-02-09.
//

import SwiftUI
import CoreData
import FirebaseAuth

struct ListingsView: View {

    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var auth: AuthService

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FavoriteListing.savedAt, ascending: false)],
        animation: .default
    )
    private var favorites: FetchedResults<FavoriteListing>

    @StateObject private var vm = ListingsViewModel()

   
    @State private var searchText = ""
    @State private var minPrice: Double = 0
    @State private var maxPrice: Double = 5000
    @State private var selectedCity: String = "All"
    @State private var showFilters = false

    
    private var userId: String { auth.user?.uid ?? "" }

   
    private var favoriteIds: Set<String> {
        Set(
            favorites
                .filter { $0.userId == userId }
                .compactMap { $0.listingId }
        )
    }

    private var cityOptions: [String] {
        let cities = Set(vm.listings.map { $0.city }).sorted()
        return ["All"] + cities
    }

    private var filteredListings: [Listing] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return vm.listings.filter { listing in
            let matchesSearch =
                q.isEmpty
                || listing.title.lowercased().contains(q)
                || listing.address.lowercased().contains(q)

            let matchesPrice = listing.price >= minPrice && listing.price <= maxPrice
            let matchesCity = (selectedCity == "All") || (listing.city == selectedCity)

            return matchesSearch && matchesPrice && matchesCity
        }
    }

    private var isFilteringActive: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        || minPrice != 0
        || maxPrice != 5000
        || selectedCity != "All"
    }

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView("Loading listings...")
                } else if let msg = vm.errorMessage {
                    VStack(spacing: 12) {
                        Text("Error: \(msg)")
                        Button("Retry") { Task { await vm.loadListings() } }
                    }
                } else {
                    List {
                        Section {
                            ForEach(filteredListings) { listing in
                                NavigationLink {
                                    ListingDetailsView(listing: listing)
                                } label: {
                                    HStack(alignment: .top, spacing: 12) {
                                        if let imageUrl = listing.imageUrl,
                                           let url = URL(string: imageUrl) {
                                            AsyncImage(url: url) { image in
                                                image.resizable().scaledToFill()
                                            } placeholder: {
                                                Color.gray.opacity(0.2)
                                            }
                                            .frame(width: 80, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(listing.title).font(.headline)
                                            Text("$\(listing.price, specifier: "%.0f")").font(.subheadline)
                                            Text(listing.address).font(.caption)
                                            
                                            // Heart under address
                                            HStack(spacing: 6) {
                                                Image(systemName: favoriteIds.contains(listing.id) ? "heart.fill" : "heart")
                                                    .foregroundStyle(favoriteIds.contains(listing.id) ? .red : .secondary)
                                                
                                                if favoriteIds.contains(listing.id) {
                                                    Text("Saved")
                                                        .font(.caption)
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                toggleFavoriteFromRow(listing)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if filteredListings.isEmpty {
                                ContentUnavailableView(
                                    "No results",
                                    systemImage: "magnifyingglass",
                                    description: Text("Try changing your search or filters.")
                                )
                                .listRowSeparator(.hidden)
                            }
                            
                        } header: {
                            SearchFilterHeader(
                                searchText: $searchText,
                                showFilters: $showFilters,
                                minPrice: $minPrice,
                                maxPrice: $maxPrice,
                                selectedCity: $selectedCity,
                                cityOptions: cityOptions,
                                resultsCount: filteredListings.count,
                                isFilteringActive: isFilteringActive,
                                onClear: clearFilters
                            )
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await vm.loadListings()
                    }
                }
            }
            .navigationTitle("Listings")
            .task {
                await vm.loadListings()
                vm.startRealtimeUpdates()
            }
            .onDisappear {
                vm.stopRealtimeUpdates()
            }
        }
    }

    private func toggleFavoriteFromRow(_ listing: Listing) {
        guard !userId.isEmpty else { return }

        if favoriteIds.contains(listing.id) {
            removeFavoriteFromRow(listing)
        } else {
            saveFavoriteFromRow(listing)
        }
    }

    private func saveFavoriteFromRow(_ listing: Listing) {
        guard !userId.isEmpty else { return }
        guard !favoriteIds.contains(listing.id) else { return }

        let fav = FavoriteListing(context: context)
        fav.favoriteId = UUID().uuidString
        fav.userId = userId
        fav.listingId = listing.id
        fav.title = listing.title
        fav.price = listing.price
        fav.address = listing.address
        fav.city = listing.city
        fav.lat = listing.lat
        fav.long = listing.long
        fav.imageUrl = listing.imageUrl
        fav.savedAt = Date()

        do {
            try context.save()
        } catch {
            print("Save favorite from row error:", error)
        }
    }

    private func removeFavoriteFromRow(_ listing: Listing) {
        guard !userId.isEmpty else { return }

        let request: NSFetchRequest<FavoriteListing> = FavoriteListing.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@ AND listingId == %@", userId, listing.id)

        do {
            let results = try context.fetch(request)
            results.forEach(context.delete)
            try context.save()
        } catch {
            print("Remove favorite from row error:", error)
        }
    }



    private func clearFilters() {
        searchText = ""
        minPrice = 0
        maxPrice = 5000
        selectedCity = "All"
        showFilters = false
    }
}
