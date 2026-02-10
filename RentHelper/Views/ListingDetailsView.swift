//
//  ListingDetailsView.swift
//  RentHelper
//
//  Created by Naomi on 2026-02-09.
//  Modified by Betty 
//

import SwiftUI
import CoreData
import FirebaseAuth

struct ListingDetailsView: View {
    let listing: Listing

    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var auth: AuthService

    @State private var isFavorite = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(listing.title).font(.title2).bold()
                Text("$\(listing.price, specifier: "%.0f")").font(.title3)

                Text("\(listing.address), \(listing.city)")
                    .font(.subheadline)

                Text(listing.description)
                    .font(.body)

                HStack {
                    if isFavorite {
                        Button {
                            removeFavorite()
                        } label: {
                            Label("Remove Favorite", systemImage: "heart.slash")
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    } else {
                        Button {
                            saveFavorite()
                        } label: {
                            Label("Save to Favorites", systemImage: "heart")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            checkIfFavorite()
        }
    }

    private func saveFavorite() {
        guard let userId = auth.user?.uid, !userId.isEmpty else { return }

        let listingId = listing.id   // use .uuidString if UUID

        let request: NSFetchRequest<FavoriteListing> = FavoriteListing.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(
            format: "userId == %@ AND listingId == %@",
            userId,
            listingId
        )

        do {
            if try context.fetch(request).first != nil {
                isFavorite = true
                return
            }

            let fav = FavoriteListing(context: context)
            fav.favoriteId = UUID().uuidString
            fav.userId = userId
            fav.listingId = listingId
            fav.title = listing.title
            fav.price = listing.price
            fav.address = listing.address
            fav.city = listing.city
            fav.savedAt = Date()

            try context.save()
            isFavorite = true
        } catch {
            print("Save favorite error:", error)
        }
    }

    private func removeFavorite() {
        guard let userId = auth.user?.uid, !userId.isEmpty else { return }

        let listingId = listing.id   // use .uuidString if UUID

        let request: NSFetchRequest<FavoriteListing> = FavoriteListing.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(
            format: "userId == %@ AND listingId == %@",
            userId,
            listingId
        )

        do {
            let results = try context.fetch(request)
            results.forEach(context.delete)
            try context.save()
            isFavorite = false
        } catch {
            print("Remove favorite error:", error)
        }
    }


    private func checkIfFavorite() {
        guard let userId = auth.user?.uid, !userId.isEmpty else { return }

        let listingId = listing.id

        let request: NSFetchRequest<FavoriteListing> = FavoriteListing.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "userId == %@ AND listingId == %@", userId, listingId)

        if let _ = try? context.fetch(request).first {
            isFavorite = true
        }
    }
}

