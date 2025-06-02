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
                
                // Price information
                VStack(alignment: .leading, spacing: 2) {
                    Text(listing.formattedPrice)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(listing.formattedPricePerUnit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Tags flow layout - show all tags below price
                if !listing.tags.isEmpty {
                    TagFlowLayout(tags: listing.tags.sorted(by: { $0.name < $1.name }))
                        .padding(.top, 4)
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

// Compact flow layout for tags in property list rows
struct TagFlowLayout: View {
    let tags: [PropertyTag]
    
    var body: some View {
        FlexibleWrapView(data: tags, spacing: 3) { tag in
            Text(tag.name)
                .font(.caption2)
                .fontWeight(.medium)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(tag.swiftUiColor.opacity(0.15))
                .foregroundColor(tag.swiftUiColor)
                .cornerRadius(3)
                .lineLimit(1)
        }
    }
}

// Flexible wrap view that dynamically adjusts to available width
struct FlexibleWrapView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    let data: Data
    let spacing: CGFloat
    let content: (Data.Element) -> Content
    
    @State private var totalHeight = CGFloat.zero
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)
    }
    
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(Array(data.enumerated()), id: \.element.id) { index, item in
                content(item)
                    .padding(.all, spacing / 2)
                    .alignmentGuide(.leading, computeValue: { dimensions in
                        if (abs(width - dimensions.width) > geometry.size.width) {
                            width = 0
                            height -= dimensions.height + spacing
                        }
                        let result = width
                        if index == data.count - 1 {
                            width = 0
                        } else {
                            width -= dimensions.width + spacing
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { dimensions in
                        let result = height
                        if index == data.count - 1 {
                            height = 0
                        }
                        return result
                    })
            }
        }
        .background(GeometryReader { geometry in
            Color.clear
                .preference(key: ViewHeightKey.self,
                           value: geometry.frame(in: .local).size.height)
        })
        .onPreferenceChange(ViewHeightKey.self) { height in
            DispatchQueue.main.async {
                self.totalHeight = height
            }
        }
    }
}

struct ViewHeightKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
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