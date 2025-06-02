import SwiftUI

struct ComparePropertiesView: View {
    let listings: [PropertyListing]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Headers
                    HStack(spacing: 1) {
                        Text("Property")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(width: 120, alignment: .leading)
                            .padding()
#if os(iOS)
                            .background(Color(.systemGroupedBackground))
#else
                            .background(Color(NSColor.controlBackgroundColor))
#endif
                        
                        // Property columns
                        ForEach(listings, id: \.title) { listing in
                            VStack(spacing: 4) {
                                Text(listing.title)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                
                                // Show rating instead of favorite
                                if let propertyRating = listing.propertyRating, propertyRating != .none {
                                    HStack(spacing: 4) {
                                        Image(systemName: propertyRating.systemImage)
                                            .foregroundColor(Color(propertyRating.color))
                                            .font(.caption)
                                        Text(propertyRating.displayName)
                                            .font(.caption2)
                                            .foregroundColor(Color(propertyRating.color))
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 12)
#if os(iOS)
                            .background(Color(.systemGroupedBackground))
#else
                            .background(Color(NSColor.controlBackgroundColor))
#endif
                        }
                    }
                    
                    Divider()
                    
                    // Comparison rows
                    ComparisonRow(
                        label: "Price",
                        values: listings.map { $0.formattedPrice },
                        highlightBest: true,
                        bestComparison: { values in
                            let prices = listings.map { $0.price }
                            let minPrice = prices.min() ?? 0
                            return prices.map { $0 == minPrice }
                        }
                    )
                    
                    ComparisonRow(
                        label: "Size",
                        values: listings.map { $0.formattedSize },
                        highlightBest: true,
                        bestComparison: { _ in
                            let sizes = listings.map { $0.size }
                            let maxSize = sizes.max() ?? 0
                            return sizes.map { $0 == maxSize }
                        }
                    )
                    
                    ComparisonRow(
                        label: "Bedrooms",
                        values: listings.map { "\($0.bedrooms)" },
                        highlightBest: true,
                        bestComparison: { _ in
                            let bedrooms = listings.map { $0.bedrooms }
                            let maxBedrooms = bedrooms.max() ?? 0
                            return bedrooms.map { $0 == maxBedrooms }
                        }
                    )
                    
                    ComparisonRow(
                        label: "Bathrooms",
                        values: listings.map { $0.bathroomText },
                        highlightBest: true,
                        bestComparison: { _ in
                            let bathrooms = listings.map { $0.bathrooms }
                            let maxBathrooms = bathrooms.max() ?? 0
                            return bathrooms.map { $0 == maxBathrooms }
                        }
                    )
                    
                    ComparisonRow(
                        label: "Type",
                        values: listings.map { $0.propertyType.rawValue }
                    )
                    
                    ComparisonRow(
                        label: "Rating",
                        values: listings.map { listing in
                            listing.propertyRating?.displayName ?? "Not rated"
                        },
                        highlightBest: true,
                        bestComparison: { _ in
                            let ratingValues = listings.map { $0.propertyRating?.rawValue ?? "none" }
                            let bestRating = ratingValues.max() ?? "none"
                            return ratingValues.map { $0 == bestRating && $0 != "none" }
                        }
                    )
                    
                    ComparisonRow(
                        label: "Price/\(listings.first?.sizeUnit ?? "unit")",
                        values: listings.map { $0.formattedPricePerUnit },
                        highlightBest: true,
                        bestComparison: { _ in
                            let pricesPerUnit = listings.map { $0.price / $0.size }
                            let minPricePerUnit = pricesPerUnit.min() ?? 0
                            return pricesPerUnit.map { $0 == minPricePerUnit }
                        }
                    )
                    
                    ComparisonRow(
                        label: "Location",
                        values: listings.map { $0.location }
                    )
                    
                    // Tags comparison
                    VStack(spacing: 1) {
                        HStack(spacing: 1) {
                            Text("Tags")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .frame(width: 120, alignment: .leading)
                                .padding()
#if os(iOS)
                                .background(Color(.secondarySystemGroupedBackground))
#else
                                .background(Color(NSColor.separatorColor).opacity(0.2))
#endif
                            
                            ForEach(listings, id: \.title) { listing in
                                ScrollView {
                                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 4) {
                                        ForEach(listing.tags, id: \.name) { tag in
                                            Text(tag.name)
                                                .font(.caption2)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color(tag.color.rawValue).opacity(0.2))
                                                .foregroundStyle(Color(tag.color.rawValue))
                                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, minHeight: 80)
                                .padding(8)
#if os(iOS)
                                .background(Color(.secondarySystemGroupedBackground))
#else
                                .background(Color(NSColor.separatorColor).opacity(0.2))
#endif
                            }
                        }
                        Divider()
                    }
                    
                    // Notes comparison
                    VStack(spacing: 1) {
                        HStack(spacing: 1) {
                            Text("Notes")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .frame(width: 120, alignment: .leading)
                                .padding()
#if os(iOS)
                                .background(Color(.tertiarySystemGroupedBackground))
#else
                                .background(Color(NSColor.separatorColor).opacity(0.1))
#endif
                            
                            ForEach(listings, id: \.title) { listing in
                                ScrollView {
                                    Text(listing.notes.isEmpty ? "No notes" : listing.notes)
                                        .font(.caption)
                                        .foregroundStyle(listing.notes.isEmpty ? .secondary : .primary)
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, alignment: .topLeading)
                                }
                                .frame(maxWidth: .infinity, minHeight: 80)
                                .padding(8)
#if os(iOS)
                                .background(Color(.tertiarySystemGroupedBackground))
#else
                                .background(Color(NSColor.separatorColor).opacity(0.1))
#endif
                            }
                        }
                    }
                }
            }
            .navigationTitle("Compare Properties")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ComparisonRow: View {
    let label: String
    let values: [String]
    var highlightBest: Bool = false
    var bestComparison: (([String]) -> [Bool])? = nil
    
    var body: some View {
        VStack(spacing: 1) {
            HStack(spacing: 1) {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(width: 120, alignment: .leading)
                    .padding()
                    .background(labelBackgroundColor)
                
                ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                    let isBest = highlightBest && (bestComparison?(values)[index] == true)
                    
                    Text(value)
                        .font(.subheadline)
                        .fontWeight(isBest ? .semibold : .regular)
                        .foregroundStyle(isBest ? .green : .primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(backgroundColorForCell(isBest: isBest))
                        .overlay(
                            isBest ? RoundedRectangle(cornerRadius: 0).stroke(Color.green.opacity(0.3), lineWidth: 1) : nil
                        )
                }
            }
            Divider()
        }
    }
    
    private var labelBackgroundColor: Color {
#if os(iOS)
        Color(.secondarySystemGroupedBackground)
#else
        Color(NSColor.separatorColor).opacity(0.2)
#endif
    }
    
    private func backgroundColorForCell(isBest: Bool) -> Color {
        if isBest {
            return Color.green.opacity(0.1)
        } else {
#if os(iOS)
            return Color(.secondarySystemGroupedBackground)
#else
            return Color(NSColor.separatorColor).opacity(0.2)
#endif
        }
    }
}

#Preview {
    ComparePropertiesView(listings: Array(PropertyListing.sampleData.prefix(3)))
} 