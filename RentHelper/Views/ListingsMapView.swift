//
//  ListingsMapView.swift
//  RentHelper
//
//  Created by Negar Pirasteh on 2026-02-28.
//  Edited by Naomi on 2026-03-02
//

import SwiftUI
import MapKit

struct ListingsMapView: View {
    @Binding var selectedTab: Int

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

                Group {
                    if vm.isLoading {
                        ProgressView("Loading map...")

                    } else if let msg = vm.errorMessage {

                        VStack(spacing: 12) {
                            Text("Error: \(msg)")
                            Button("Retry") {
                                Task { await vm.retry() }
                            }
                        }

                    } else {

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
                                    withAnimation {
                                        selectedListing = listing
                                    }
                                } label: {
                                    markerView(listing)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                zoomButtons
                if let item = selectedListing {
                    popupCard(item)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle("Map")

            .task {
                await vm.loadListings()
                vm.startRealtimeUpdates()
                updateRegionIfNeeded()
            }

            .onChange(of: vm.listings.count) { _ in
                updateRegionIfNeeded()
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

    private func markerView(_ listing: Listing) -> some View {
        let isSelected = (selectedListing?.id == listing.id)

        return VStack(spacing: 4) {

            Image(systemName: "house.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
                .frame(width: 36, height: 36)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.black.opacity(0.55) : Color.clear, lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.2), radius: 4)

            Text("$\(listing.price, specifier: "%.0f")")
                .font(.caption2)
                .foregroundColor(.black)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: .black.opacity(0.15), radius: 3)
        }
    }

    private var zoomButtons: some View {
        VStack {
            Spacer()

            HStack {
                Spacer()

                VStack(spacing: 16) {

                    Button(action: zoomIn) {
                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 64, height: 64)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 5)
                    }

                    Button(action: zoomOut) {
                        Image(systemName: "minus")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 64, height: 64)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 5)
                    }
                }
                .padding(.trailing, 16)
                .padding(.bottom, 110)
            }
        }
    }

    private func popupCard(_ listing: Listing) -> some View {
        VStack {
            Spacer()

            VStack(alignment: .leading, spacing: 10) {

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("$\(listing.price, specifier: "%.0f")")
                            .font(.headline)

                        Text("\(listing.address), \(listing.city)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    Spacer()

                    Button {
                        withAnimation { selectedListing = nil }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(width: 28, height: 28)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }

                HStack(spacing: 12) {

                    Button {
                        goToDetails = true
                    } label: {
                        Label("Details", systemImage: "info.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.gray)

                    Button {
                        selectedTab = 0
                        withAnimation { selectedListing = nil }
                    } label: {
                        Label("View more places", systemImage: "list.bullet")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.gray)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.15), radius: 10)
            .padding(.horizontal, 16)
            .padding(.bottom, 90)
        }
    }

    private var validListings: [Listing] {
        vm.listings.filter { listing in
            (-90...90).contains(listing.lat) &&
            (-180...180).contains(listing.long)
        }
    }

    private func updateRegionIfNeeded() {
        guard let first = validListings.first else { return }
        region.center = CLLocationCoordinate2D(latitude: first.lat, longitude: first.long)
    }
    private func zoomIn() {
        let newLat = max(region.span.latitudeDelta * 0.8, minDelta)
        let newLong = max(region.span.longitudeDelta * 0.8, minDelta)

        withAnimation {
            region.span = MKCoordinateSpan(latitudeDelta: newLat, longitudeDelta: newLong)
        }
    }

    private func zoomOut() {
        let newLat = min(region.span.latitudeDelta * 1.2, maxDelta)
        let newLong = min(region.span.longitudeDelta * 1.2, maxDelta)

        withAnimation {
            region.span = MKCoordinateSpan(latitudeDelta: newLat, longitudeDelta: newLong)
        }
    }
}
