//
//  Favorites.swift
//  RentHelper
//
//  Created by Betty on 2026-02-09.
//
import SwiftUI
import CoreData

struct FavoritesView: View {
    let userId: String

    @FetchRequest private var favorites: FetchedResults<FavoriteListing>

    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 12)
    ]

    init(userId: String) {
        self.userId = userId
        _favorites = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \FavoriteListing.savedAt, ascending: false)],
            predicate: NSPredicate(format: "userId == %@", userId),
            animation: .default
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppPageBackground()

                if favorites.isEmpty {
                    ContentUnavailableView(
                        "No favorites yet",
                        systemImage: "heart",
                        description: Text("Save apartments from listings to see them here.")
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(favorites, id: \.objectID) { fav in
                                NavigationLink {
                                    ListingDetailsView(listing: Listing(from: fav))
                                } label: {
                                    favoriteCard(fav)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Favorites")
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.white.opacity(0.85), for: .navigationBar)
        }
    }

    private func favoriteCard(_ fav: FavoriteListing) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Group {
                if let imageUrl = fav.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ZStack { Color.gray.opacity(0.12); ProgressView() }
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure:
                            ZStack { Color.gray.opacity(0.12); Image(systemName: "photo") }
                        @unknown default:
                            Color.gray.opacity(0.12)
                        }
                    }
                } else {
                    ZStack {
                        Color.gray.opacity(0.12)
                        Image(systemName: "house.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(height: 118)
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 6) {
                Text(fav.title ?? "Untitled")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(2)

                Text((fav.price).formatted(.currency(code: "CAD")))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppTheme.accent)

                Text(fav.city ?? "")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
            }
            .padding(10)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .premiumCard(cornerRadius: 16)
    }
}
