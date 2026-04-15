//
//  ListingCardView.swift
//  RentHelper
//
//  Created by Negar on 2026-03-31.
//
import SwiftUI

struct ListingCardView: View {
    let listing: Listing
    let isFavorite: Bool
    let onToggleFavorite: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                imageLayer

                LinearGradient(
                    colors: [.clear, .black.opacity(0.18)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                Button(action: onToggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(isFavorite ? Color.red : AppTheme.textPrimary)
                        .frame(width: 32, height: 32)
                        .background(.white.opacity(0.96), in: Circle())
                }
                .buttonStyle(.plain)
                .padding(10)
            }
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.black.opacity(0.08))
                    .frame(height: 1)
            }

            HStack(alignment: .top, spacing: 10) {
                Text(listing.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)

                Text(listing.price.formatted(.currency(code: "CAD")))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppTheme.accent)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(.white, in: RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
        }
        .frame(height: 214)
        .background(Color.white.opacity(0.96))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.9), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 10, y: 5)
    }

    @ViewBuilder
    private var imageLayer: some View {
        if let imageUrl = listing.imageUrl, let url = URL(string: imageUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Color.gray.opacity(0.14)
                        ProgressView()
                    }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    ZStack {
                        Color.gray.opacity(0.14)
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                @unknown default:
                    Color.gray.opacity(0.14)
                }
            }
        } else {
            ZStack {
                Color.gray.opacity(0.14)
                Image(systemName: "house.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
