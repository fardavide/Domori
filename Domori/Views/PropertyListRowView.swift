import SwiftUI

struct PropertyListRowView: View {
    let listing: PropertyListing
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Property type icon
            Image(systemName: listing.propertyType.systemImage)
                .font(.title2)
                .foregroundStyle(.secondary)
                .frame(width: 32, height: 32)
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(listing.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    if listing.isFavorite {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
                
                Text(listing.address)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(listing.formattedPrice)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    if listing.rating > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            Text(String(format: "%.1f", listing.rating))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                HStack(spacing: 16) {
                    Label("\(listing.bedrooms)", systemImage: "bed.double")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Label(listing.bathroomText, systemImage: "shower")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Label(listing.formattedSize, systemImage: "square")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                
                if !listing.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(listing.tags.prefix(3), id: \.name) { tag in
                                Text(tag.name)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color(tag.color.rawValue).opacity(0.2))
                                    .foregroundStyle(Color(tag.color.rawValue))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                            
                            if listing.tags.count > 3 {
                                Text("+\(listing.tags.count - 3)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        ForEach(PropertyListing.sampleData, id: \.title) { listing in
            PropertyListRowView(listing: listing)
        }
    }
} 