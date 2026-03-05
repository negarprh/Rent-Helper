//
//  SearchFilterHeader.swift
//  RentHelper
//
//  Created by Betty Dang on 2026-03-01.
//

import SwiftUI

struct SearchFilterHeader: View {
    @Binding var searchText: String
    @Binding var showFilters: Bool

    @Binding var minPrice: Double
    @Binding var maxPrice: Double
    @Binding var selectedCity: String

    let cityOptions: [String]
    let resultsCount: Int
    let isFilteringActive: Bool
    let onClear: () -> Void

    var body: some View {
        VStack(spacing: 10) {

            HStack(spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)

                    TextField("Search title or address", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(.thinMaterial)
                .clipShape(Capsule())

                Text("\(resultsCount)")
                    .font(.subheadline)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.thinMaterial)
                    .clipShape(Capsule())
                    .accessibilityLabel("\(resultsCount) results")
            }

            HStack {
                Button {
                    withAnimation(.easeInOut) {
                        showFilters.toggle()
                    }
                } label: {
                    Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                }
                .buttonStyle(.bordered)

                Spacer()

                if isFilteringActive {
                    Button("Clear") {
                        onClear()
                    }
                    .buttonStyle(.bordered)
                }
            }

            if showFilters {
                VStack(alignment: .leading, spacing: 10) {

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Price Range")
                            .font(.subheadline)

                        HStack(spacing: 10) {
                            TextField("Min", value: $minPrice, format: .number)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                                .frame(maxWidth: 120)
                                .onChange(of: minPrice) { _, _ in
                                    if minPrice < 0 { minPrice = 0 }
                                    if minPrice > maxPrice { minPrice = maxPrice }
                                }

                            Text("to")
                                .foregroundStyle(.secondary)

                            TextField("Max", value: $maxPrice, format: .number)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                                .frame(maxWidth: 120)
                                .onChange(of: maxPrice) { _, _ in
                                    if maxPrice < 0 { maxPrice = 0 }
                                    if maxPrice < minPrice { maxPrice = minPrice }
                                }
                        }
                    }

                    Text("City")
                        .font(.subheadline)
                    Picker("City", selection: $selectedCity) {
                        ForEach(cityOptions, id: \.self) { city in
                            Text(city).tag(city)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .padding(.top, 2)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}
