import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ComparePropertiesView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(TagQuery.self) private var tagQuery
  private var allTags: [PropertyTag] { tagQuery.all }
  
  let properties: [Property]
  
  init(properties: [Property]) {
    self.properties = properties
  }
  
  private func tagsForProperty(_ property: Property) -> [PropertyTag] {
    allTags.filter { tag in
      guard let tagId = tag.id else { return false }
      return property.tagIds.contains(tagId)
    }
  }
  
  private var headerBackgroundColor: Color {
#if os(iOS)
    Color(.systemGroupedBackground)
#else
    Color.gray.opacity(0.1)
#endif
  }
  
  private var labelBackgroundColor: Color {
#if os(iOS)
    Color(.secondarySystemGroupedBackground)
#else
    Color.gray.opacity(0.05)
#endif
  }
  
  private var cellBackgroundColor: Color {
#if os(iOS)
    Color(.secondarySystemGroupedBackground)
#else
    Color.gray.opacity(0.05)
#endif
  }
  
  private var priceComparisonRow: some View {
    ComparisonRow(
      label: "Price",
      values: properties.map { $0.formattedPrice },
      highlightBest: true,
      bestComparison: priceComparison
    )
  }
  
  private var sizeComparisonRow: some View {
    ComparisonRow(
      label: "Size",
      values: properties.map { $0.formattedSize },
      highlightBest: true,
      bestComparison: sizeComparison
    )
  }
  
  private var bedroomsComparisonRow: some View {
    ComparisonRow(
      label: "Bedrooms",
      values: properties.map { "\($0.bedrooms)" },
      highlightBest: true,
      bestComparison: bedroomsComparison
    )
  }
  
  private var bathroomsComparisonRow: some View {
    ComparisonRow(
      label: "Bathrooms",
      values: properties.map { $0.bathroomText },
      highlightBest: true,
      bestComparison: bathroomsComparison
    )
  }
  
  private var typeComparisonRow: some View {
    ComparisonRow(
      label: "Type",
      values: properties.map { $0.type.rawValue }
    )
  }
  
  private var ratingComparisonRow: some View {
    ComparisonRow(
      label: "Rating",
      values: properties.map { listing in
        listing.rating.displayName
      },
      highlightBest: true,
      bestComparison: ratingComparison
    )
  }
  
  private var pricePerUnitComparisonRow: some View {
    ComparisonRow(
      label: "Price/\(properties.first?.sizeUnit ?? "unit")",
      values: properties.map { $0.formattedPricePerUnit },
      highlightBest: true,
      bestComparison: pricePerUnitComparison
    )
  }
  
  private var locationComparisonRow: some View {
    ComparisonRow(
      label: "Location",
      values: properties.map { $0.location }
    )
  }
  
  private func priceComparison(_ values: [String]) -> [Bool] {
    let prices = properties.map { $0.price }
    let minPrice = prices.min() ?? 0
    return prices.map { $0 == minPrice }
  }
  
  private func sizeComparison(_ values: [String]) -> [Bool] {
    let sizes = properties.map { $0.size }
    let maxSize = sizes.max() ?? 0
    return sizes.map { $0 == maxSize }
  }
  
  private func bedroomsComparison(_ values: [String]) -> [Bool] {
    let bedrooms = properties.map { $0.bedrooms }
    let maxBedrooms = bedrooms.max() ?? 0
    return bedrooms.map { $0 == maxBedrooms }
  }
  
  private func bathroomsComparison(_ values: [String]) -> [Bool] {
    let bathrooms = properties.map { $0.bathrooms }
    let maxBathrooms = bathrooms.max() ?? 0
    return bathrooms.map { $0 == maxBathrooms }
  }
  
  private func ratingComparison(_ values: [String]) -> [Bool] {
    let ratingValues = properties.map { $0.rating.rawValue }
    let bestRating = ratingValues.max() ?? "none"
    return ratingValues.map { $0 == bestRating && $0 != "none" }
  }
  
  private func pricePerUnitComparison(_ values: [String]) -> [Bool] {
    let pricesPerUnit = properties.map { $0.price / $0.size }
    let minPricePerUnit = pricesPerUnit.min() ?? 0
    return pricesPerUnit.map { $0 == minPricePerUnit }
  }
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 0) {
          // Header row with property titles
          HStack(spacing: 1) {
            Text("")
              .frame(width: 120)
              .padding()
            
            ForEach(properties, id: \.id) { listing in
              VStack(alignment: .leading, spacing: 4) {
                Text(listing.title)
                  .font(.subheadline)
                  .fontWeight(.semibold)
                  .lineLimit(2)
                
                Text(listing.location)
                  .font(.caption)
                  .foregroundStyle(.secondary)
                  .lineLimit(1)
              }
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding()
              .background(headerBackgroundColor)
            }
          }
          .background(Color.primary.opacity(0.1))
          
          Divider()
          
          // Comparison rows
          priceComparisonRow
          sizeComparisonRow
          bedroomsComparisonRow
          bathroomsComparisonRow
          typeComparisonRow
          ratingComparisonRow
          pricePerUnitComparisonRow
          locationComparisonRow
          
          // Tags comparison
          VStack(spacing: 1) {
            HStack(spacing: 1) {
              Text("Tags")
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 120, alignment: .leading)
                .padding()
                .background(labelBackgroundColor)
              
              ForEach(properties, id: \.id) { listing in
                ScrollView {
                  LazyVGrid(columns: [GridItem(.flexible())], spacing: 4) {
                    ForEach(tagsForProperty(listing), id: \.name) { tag in
                      Text(tag.name)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(tag.swiftUiColor.opacity(0.2))
                        .foregroundStyle(tag.swiftUiColor)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                  }
                }
                .frame(maxWidth: .infinity, minHeight: 80)
                .padding(8)
                .background(cellBackgroundColor)
              }
            }
            Divider()
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
    ComparePropertiesView(properties: Array(Property.sampleData.prefix(3)))
} 
