import SwiftUI

struct PropertyDetailView: View {
    @Bindable var listing: PropertyListing
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header - Basic Info Only
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(listing.title)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(listing.location)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            // Display link if available
                            if let link = listing.link, !link.isEmpty {
                                Button(action: {
                                    if let url = URL(string: link) {
#if os(iOS)
                                        UIApplication.shared.open(url)
#else
                                        NSWorkspace.shared.open(url)
#endif
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "link")
                                        Text("View Listing")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text(listing.formattedPrice)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Divider()
                    
                    // Property details row
                    HStack(spacing: 24) {
                        VStack(alignment: .leading) {
                            Text("Size")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(listing.formattedSize)
                                .font(.title3)
                                .fontWeight(.medium)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Type")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Label(listing.propertyType.rawValue, systemImage: listing.propertyType.systemImage)
                                .font(.title3)
                                .fontWeight(.medium)
                        }
                    }
                    
                    // Bed/Bath info and price per unit
                    HStack(spacing: 24) {
                        if listing.bedrooms > 0 {
                            Label("\(listing.bedrooms) bed", systemImage: "bed.double")
                        }
                        Label("\(listing.bathroomText) bath", systemImage: "shower")
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Price per unit")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(listing.formattedPricePerUnit)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding()
                .background(systemBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                
                // Rating Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Rating")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    // Inline Rating Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Rating")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        InlineRatingPicker(
                            selectedRating: Binding(
                                get: { listing.propertyRating ?? .none },
                                set: { newRating in
                                    listing.updateRating(newRating)
                                    try? modelContext.save()
                                }
                            )
                        )
                    }
                }
                .padding()
                .background(systemBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)

                // Tags
                if !listing.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tags")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            ForEach(listing.tags.sorted(by: { $0.name < $1.name }), id: \.name) { tag in
                                HStack {
                                    Text(tag.name)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(tag.color.rawValue))
                                .clipShape(Capsule())
                            }
                        }
                    }
                    .padding()
                    .background(systemBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                }
                
                // Property Information
                VStack(alignment: .leading, spacing: 16) {
                    Text("Property Information")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 8) {
                        detailRow("Created", value: listing.createdDate.formatted(date: .abbreviated, time: .omitted))
                        detailRow("Updated", value: listing.updatedDate.formatted(date: .abbreviated, time: .omitted))
                        detailRow("Property Type", value: listing.propertyType.rawValue)
                        detailRow("Bedrooms", value: "\(listing.bedrooms)")
                        detailRow("Bathrooms", value: listing.bathroomText)
                        detailRow("Size", value: listing.formattedSize)
                    }
                }
                .padding()
                .background(systemBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
            }
            .padding()
        }
        .navigationTitle("Property Details")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            AddPropertyView(listing: listing)
        }
    }
    
    private func detailRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
    
    private var systemBackgroundColor: Color {
#if os(iOS)
        Color(.systemBackground)
#else
        Color(NSColor.controlBackgroundColor)
#endif
    }
}

// MARK: - Inline Rating Picker Component
struct InlineRatingPicker: View {
    @Binding var selectedRating: PropertyRating
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            ForEach(PropertyRating.allCases, id: \.self) { rating in
                ratingButton(for: rating)
            }
        }
    }
    
    private func ratingButton(for rating: PropertyRating) -> some View {
        Button(action: {
            selectedRating = rating
        }) {
            HStack(spacing: 8) {
                Image(systemName: rating.systemImage)
                    .foregroundColor(Color(rating.color))
                    .font(.callout)
                
                Text(rating.displayName)
                    .font(.caption)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if selectedRating == rating {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
            }
            .padding(8)
            .background(ratingBackground(for: rating))
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func ratingBackground(for rating: PropertyRating) -> some View {
        let isSelected = selectedRating == rating
        let fillColor = isSelected ? Color(rating.color).opacity(0.1) : systemGray6Color
        let strokeColor = isSelected ? Color(rating.color).opacity(0.3) : Color.clear
        
        return RoundedRectangle(cornerRadius: 8)
            .fill(fillColor)
            .stroke(strokeColor, lineWidth: 1)
    }
    
    private var systemGray6Color: Color {
#if os(iOS)
        Color(.systemGray6)
#else
        Color(NSColor.controlBackgroundColor)
#endif
    }
}

#Preview {
    NavigationView {
        PropertyDetailView(listing: PropertyListing.sampleData[0])
    }
    .modelContainer(for: PropertyListing.self, inMemory: true)
} 