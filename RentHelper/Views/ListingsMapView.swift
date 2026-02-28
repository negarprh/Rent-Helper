//
//  ListingsMapView.swift
//  RentHelper
//
//  Created by Negar Pirasteh on 2026-02-28.
//

import SwiftUI
import MapKit

struct ListingsMapView: View {
    @StateObject private var vm = ListingsViewModel()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.5017, longitude: -73.5673),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )

    var body: some View {
        NavigationStack {
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
                    Map(coordinateRegion: $region, annotationItems: validListings) { listing in
                        MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: listing.lat, longitude: listing.long)) {
                            VStack(spacing: 4) {
                                Image(systemName: "house.fill")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .padding(8)
                                    .background(.blue)
                                    .clipShape(Circle())
                                Text("$\(listing.price, specifier: "%.0f")")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.thinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                        }
                    }
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
        }
    }

    private var validListings: [Listing] {
        vm.listings.filter { listing in
            (-90...90).contains(listing.lat) && (-180...180).contains(listing.long)
        }
    }

    private func updateRegionIfNeeded() {
        guard let first = validListings.first else { return }
        region.center = CLLocationCoordinate2D(latitude: first.lat, longitude: first.long)
    }
}
