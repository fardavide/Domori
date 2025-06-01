import SwiftUI

struct PropertyListRowView: View {
    let listing: PropertyListing
    let isSelected: Bool
    let onSelectionChanged: (Bool) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title and Rating
            HStack {
                Text(listing.title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                // Small rating indicator
                if let propertyRating = listing.propertyRating, propertyRating != .none {
                    Circle()
                        .fill(Color(propertyRating.color))
                        .frame(width: 8, height: 8)
                }
            }
            
            // Address
            Text(listing.address)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            // Property details
            HStack(spacing: 16) {
                Label(listing.propertyType.rawValue, systemImage: listing.propertyType.systemImage)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if listing.bedrooms > 0 {
                    Label("\(listing.bedrooms)", systemImage: "bed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Label(listing.bathroomText, systemImage: "shower")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Label(listing.formattedSize, systemImage: "square")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            // Price
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(listing.formattedPrice)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(listing.formattedPricePerUnit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Tags preview
                if !listing.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(Array(listing.tags.prefix(2)), id: \.name) { tag in
                            Text(tag.name)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(tag.color.rawValue).opacity(0.2))
                                .foregroundColor(Color(tag.color.rawValue))
                                .cornerRadius(4)
                        }
                        
                        if listing.tags.count > 2 {
                            Text("+\(listing.tags.count - 2)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
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