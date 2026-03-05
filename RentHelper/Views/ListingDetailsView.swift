//
//  ListingDetailsView.swift
//  RentHelper
//
//  Created by Naomi on 2026-02-09.
//  Edited by Naomi on 2026-03-02
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

            VStack(alignment: .leading, spacing: 16) {

                if let urlString = listing.imageUrl,
                   let url = URL(string: urlString) {

                    AsyncImage(url: url) { phase in
                        switch phase {

                        case .empty:
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(.ultraThinMaterial)

                                ProgressView()
                            }
                            .frame(height: 230)
                            .padding(.horizontal)

                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 230)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .cornerRadius(14)
                                .padding(.horizontal)

                        case .failure:
                            fallbackImage
                                .padding(.horizontal)

                        @unknown default:
                            EmptyView()
                        }
                    }

                } else {
                    fallbackImage
                        .padding(.horizontal)
                }

                VStack(alignment: .leading, spacing: 12) {

                    Text(listing.title)
                        .font(.title2)
                        .bold()

                    Text("$\(listing.price, specifier: "%.0f")")
                        .font(.title3)

                    Text("\(listing.address), \(listing.city)")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text(listing.description)
                        .font(.body)

                    if isFavorite {

                        Button {
                            removeFavorite()
                        } label: {
                            Label("Remove Favorite", systemImage: "heart.slash")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.gray)

                    } else {

                        Button {
                            saveFavorite()
                        } label: {
                            Label("Save to Favorites", systemImage: "heart")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .padding(.top, 10)
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            checkIfFavorite()
        }
    }
    private var fallbackImage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)

            Image(systemName: "house.fill")
                .font(.system(size: 44, weight: .semibold))
                .foregroundColor(.gray)
        }
        .frame(height: 230)
    }

    private func saveFavorite() {
        guard let userId = auth.user?.uid, !userId.isEmpty else { return }

        let listingId = listing.id

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
            fav.lat = listing.lat
            fav.long = listing.long
            fav.imageUrl = listing.imageUrl
            fav.savedAt = Date()

            try context.save()
            isFavorite = true
        } catch {
            print("Save favorite error:", error)
        }
    }

    private func removeFavorite() {
        guard let userId = auth.user?.uid, !userId.isEmpty else { return }

        let listingId = listing.id

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
        request.predicate = NSPredicate(
            format: "userId == %@ AND listingId == %@",
            userId,
            listingId
        )

        if let _ = try? context.fetch(request).first {
            isFavorite = true
        }
    }
}
