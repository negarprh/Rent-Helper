//
//  ListingsMapView.swift
//  RentHelper
//
//  Created by Neomi Pirasteh on 2026-02-28
//
import SwiftUI
import MapKit

struct ListingsMapView: View {
    @StateObject private var vm = ListingsViewModel()

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.5017, longitude: -73.5673),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )

    @State private var minDelta: Double = 0.005
    @State private var maxDelta: Double = 3.0
    @State private var selectedListing: Listing? = nil
    @State private var goToDetails: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppPageBackground()

                Group {
                    if vm.isLoading {
                        ProgressView("Loading map...")
                    } else if let msg = vm.errorMessage {
                        VStack(spacing: 12) {
                            Text("Error: \(msg)")
                                .multilineTextAlignment(.center)
                            Button("Retry") {
                                Task { await vm.retry() }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(AppTheme.accent)
                        }
                        .padding()
                    } else {
                        mapContainer
                    }
                }
            }
            .navigationTitle("Map")
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.white.opacity(0.85), for: .navigationBar)
            .safeAreaInset(edge: .bottom) {
                if let listing = selectedListing {
                    selectedListingPanel(listing)
                        .padding(.horizontal, 14)
                        .padding(.bottom, 8)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .task {
                await vm.loadListings()
                vm.startRealtimeUpdates()
                fitRegionToListings(animated: false)
            }
            .onChange(of: vm.listings.count) { _ in
                fitRegionToListings(animated: true)
            }
            .onDisappear {
                vm.stopRealtimeUpdates()
            }
            .navigationDestination(isPresented: $goToDetails) {
                if let item = selectedListing {
                    ListingDetailsView(listing: item)
                }
            }
        }
    }

    private var mapContainer: some View {
        ZStack(alignment: .top) {
            Map(
                coordinateRegion: $region,
                annotationItems: validListings
            ) { listing in
                MapAnnotation(
                    coordinate: CLLocationCoordinate2D(
                        latitude: listing.lat,
                        longitude: listing.long
                    )
                ) {
                    Button {
                        selectListing(listing)
                    } label: {
                        markerView(listing)
                    }
                    .buttonStyle(.plain)
                }
            }
            .mapStyle(.standard)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.85), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    selectedListing = nil
                }
            }

            topMapBar
                .padding(12)

            controlsView
                .padding(14)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }

    private var topMapBar: some View {
        HStack(spacing: 10) {
            Label("\(validListings.count) listings", systemImage: "house.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.white.opacity(0.95), in: Capsule())

            Spacer()
        }
    }

    private var controlsView: some View {
        VStack(spacing: 10) {
            mapControlButton(systemImage: "plus", action: zoomIn)
            mapControlButton(systemImage: "minus", action: zoomOut)
        }
    }

    private func mapControlButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 42, height: 42)
                .background(.white.opacity(0.94), in: Circle())
                .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }

    private func markerView(_ listing: Listing) -> some View {
        let isSelected = selectedListing?.id == listing.id

        return VStack(spacing: 4) {
            Text(
                listing.price.formatted(
                    .currency(code: "CAD").precision(.fractionLength(0))
                )
            )
            .font(.caption.weight(.semibold))
            .foregroundStyle(isSelected ? .white : AppTheme.textPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                isSelected ? AppTheme.accent : Color.white.opacity(0.95),
                in: Capsule()
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.9), lineWidth: isSelected ? 0 : 1)
            )

            Circle()
                .fill(isSelected ? AppTheme.accent : .white)
                .frame(width: 8, height: 8)
        }
        .shadow(color: .black.opacity(0.18), radius: 8, y: 4)
        .scaleEffect(isSelected ? 1.06 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
    }

    private func selectedListingPanel(_ listing: Listing) -> some View {
        HStack(alignment: .top, spacing: 12) {
            listingThumbnail(listing)

            VStack(alignment: .leading, spacing: 6) {
                Text(listing.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(2)

                Text(listing.price.formatted(.currency(code: "CAD").precision(.fractionLength(0))))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppTheme.accent)

                Text("\(listing.address), \(listing.city)")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    selectedListing = nil
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .frame(width: 24, height: 24)
                    .background(.white.opacity(0.95), in: Circle())
            }
            .buttonStyle(.plain)
            .padding(8)
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                goToDetails = true
            } label: {
                Label("Details", systemImage: "info.circle")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(AppTheme.accent, in: Capsule())
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .padding(10)
        }
        .padding(12)
        .premiumCard(cornerRadius: 18)
    }

    @ViewBuilder
    private func listingThumbnail(_ listing: Listing) -> some View {
        if let imageUrl = listing.imageUrl, let url = URL(string: imageUrl) {
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
            .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            ZStack {
                Color.gray.opacity(0.12)
                Image(systemName: "house.fill")
                    .foregroundStyle(.secondary)
            }
            .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var validListings: [Listing] {
        vm.listings.filter { listing in
            (-90...90).contains(listing.lat) &&
            (-180...180).contains(listing.long)
        }
    }

    private func selectListing(_ listing: Listing) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            selectedListing = listing
        }

        withAnimation(.easeInOut(duration: 0.35)) {
            region.center = CLLocationCoordinate2D(latitude: listing.lat, longitude: listing.long)
        }
    }

    private func fitRegionToListings(animated: Bool) {
        guard !validListings.isEmpty else { return }

        let lats = validListings.map(\.lat)
        let longs = validListings.map(\.long)

        guard
            let minLat = lats.min(),
            let maxLat = lats.max(),
            let minLong = longs.min(),
            let maxLong = longs.max()
        else { return }

        let latDelta = max((maxLat - minLat) * 1.4, 0.03)
        let longDelta = max((maxLong - minLong) * 1.4, 0.03)
        let span = MKCoordinateSpan(
            latitudeDelta: min(latDelta, maxDelta),
            longitudeDelta: min(longDelta, maxDelta)
        )
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLong + maxLong) / 2
        )

        if animated {
            withAnimation(.easeInOut(duration: 0.35)) {
                region = MKCoordinateRegion(center: center, span: span)
            }
        } else {
            region = MKCoordinateRegion(center: center, span: span)
        }
    }

    private func zoomIn() {
        let newLat = max(region.span.latitudeDelta * 0.8, minDelta)
        let newLong = max(region.span.longitudeDelta * 0.8, minDelta)

        withAnimation(.easeInOut(duration: 0.2)) {
            region.span = MKCoordinateSpan(latitudeDelta: newLat, longitudeDelta: newLong)
        }
    }

    private func zoomOut() {
        let newLat = min(region.span.latitudeDelta * 1.2, maxDelta)
        let newLong = min(region.span.longitudeDelta * 1.2, maxDelta)

        withAnimation(.easeInOut(duration: 0.2)) {
            region.span = MKCoordinateSpan(latitudeDelta: newLat, longitudeDelta: newLong)
        }
    }
}
