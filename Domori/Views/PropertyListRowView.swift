import SwiftUI

struct PropertyListRowView: View {
    let listing: PropertyListing
    let isSelected: Bool
    let onSelectionChanged: (Bool) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Selection button on the far left
            Button(action: {
                onSelectionChanged(!isSelected)
            }) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .blue : .gray.opacity(0.4))
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Property type icon (small, no color) - fixed alignment
            Image(systemName: listing.propertyType.systemImage)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 16, height: 16)
            
            // Main content
            VStack(alignment: .leading, spacing: 6) {
                // Title row
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(listing.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        
                        Text(listing.location)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Rating indicator as colored circle
                    if let propertyRating = listing.propertyRating, propertyRating != .none {
                        Circle()
                            .fill(getColorForRating(propertyRating))
                            .frame(width: 12, height: 12)
                    }
                }
                
                // Property details in a more organized grid
                HStack(spacing: 16) {
                    if listing.bedrooms > 0 {
                        PropertyDetailBadge(
                            icon: "bed.double",
                            value: "\(listing.bedrooms)",
                            label: listing.bedrooms == 1 ? "bed" : "beds"
                        )
                    }
                    
                    PropertyDetailBadge(
                        icon: "shower",
                        value: listing.bathroomText,
                        label: Double(listing.bathroomText) == 1.0 ? "bath" : "baths"
                    )
                    
                    PropertyDetailBadge(
                        icon: "square",
                        value: "\(Int(listing.size))",
                        label: listing.sizeUnit
                    )
                    
                    Spacer()
                }
                
                // Price and tags row
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(listing.formattedPrice)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(listing.formattedPricePerUnit)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Tags preview with improved styling
                    if !listing.tags.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(Array(listing.tags.prefix(2)), id: \.name) { tag in
                                Text(tag.name)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(tag.color.rawValue).opacity(0.15))
                                    .foregroundColor(Color(tag.color.rawValue))
                                    .cornerRadius(6)
                            }
                            
                            if listing.tags.count > 2 {
                                Text("+\(listing.tags.count - 2)")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.15))
                                    .foregroundColor(.secondary)
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
    
    // Helper function to convert rating to proper SwiftUI Color
    private func getColorForRating(_ rating: PropertyRating) -> Color {
        switch rating {
        case .none: return .gray
        case .excluded: return .red
        case .considering: return .orange
        case .good: return .green
        case .excellent: return .blue
        }
    }
}

// Helper view for property details
struct PropertyDetailBadge: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    List {
        PropertyListRowView(
            listing: PropertyListing.sampleData[0],
            isSelected: false,
            onSelectionChanged: { _ in }
        )
        PropertyListRowView(
            listing: PropertyListing.sampleData[1],
            isSelected: true,
            onSelectionChanged: { _ in }
        )
    }
    .modelContainer(for: PropertyListing.self, inMemory: true)
} 