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
    @State private var showContactLandlord = false

    var body: some View {
        ZStack {
            AppPageBackground()

            ScrollView {

                VStack(alignment: .leading, spacing: 16) {

                    if let urlString = listing.imageUrl,
                       let url = URL(string: urlString) {

                        AsyncImage(url: url) { phase in
                            switch phase {

                            case .empty:
                                ZStack {
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(.ultraThinMaterial)

                                    ProgressView()
                                }
                                .frame(height: 210)
                                .padding(.horizontal)

                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 210)
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .cornerRadius(18)
                                    .overlay(alignment: .bottomLeading) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(listing.price.formatted(.currency(code: "CAD")))
                                                .font(.headline.weight(.bold))
                                                .foregroundStyle(.white)

                                            Text(listing.city)
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(.white.opacity(0.92))
                                        }
                                        .padding(12)
                                        .background(.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 14))
                                        .padding(12)
                                    }
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

                    VStack(alignment: .leading, spacing: 14) {

                        Text(listing.title)
                            .font(.title2)
                            .bold()
                            .lineLimit(2)
                            .foregroundStyle(AppTheme.textPrimary)

                        Text(listing.price.formatted(.currency(code: "CAD")))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.accent)

                        Text("\(listing.address), \(listing.city)")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Text(listing.description)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)

                        Button {
                            showContactLandlord = true
                        } label: {
                            Label("Contact Landlord", systemImage: "message.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.accent)

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
                    .padding(16)
                    .premiumCard(cornerRadius: 20)
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
                .padding(.top, 10)
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.white.opacity(0.85), for: .navigationBar)
        .navigationDestination(isPresented: $showContactLandlord) {
            ContactLandlordView(listing: listing)
        }
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
        .frame(height: 210)
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
