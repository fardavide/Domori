import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct PropertyListRowView: View {
  @Environment(TagQuery.self) private var tagQuery
  private var allTags: [PropertyTag] { tagQuery.all }
  
  let property: Property
  let isSelected: Bool
  let onSelectionChanged: (Bool) -> Void
  
  init(property: Property, isSelected: Bool, onSelectionChanged: @escaping (Bool) -> Void) {
    self.property = property
    self.isSelected = isSelected
    self.onSelectionChanged = onSelectionChanged
  }
  
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
      
      // Main content
      VStack(alignment: .leading, spacing: 6) {
        // Title row
        HStack(alignment: .top, spacing: 8) {
          VStack(alignment: .leading, spacing: 2) {
            HStack {
              
              // Icon
              Image(systemName: property.type.systemImage)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 16, height: 16)
              
              // Title
              Text(property.title)
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(1)
              
              Spacer()
              
              // Rating indicator as colored circle
              if property.rating != .none {
                Circle()
                  .fill(getColorForRating(property.rating))
                  .frame(width: 12, height: 12)
              }
            }
            
            if let agency = property.agency {
              Text("\(agency)")
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
            }
            
            Text(property.location)
              .font(.subheadline)
              .foregroundColor(.secondary)
              .lineLimit(1)
          }
        }
        
        // Property details in a more organized grid
        HStack(spacing: 16) {
          if property.bedrooms > 0 {
            PropertyDetailBadge(
              icon: "bed.double",
              value: "\(property.bedrooms)",
              label: property.bedrooms == 1 ? "bed" : "beds"
            )
          }
          
          PropertyDetailBadge(
            icon: "shower",
            value: property.bathroomText,
            label: Double(property.bathroomText) == 1.0 ? "bath" : "baths"
          )
          
          PropertyDetailBadge(
            icon: "square",
            value: "\(Int(property.size))",
            label: property.sizeUnit
          )
          
          Spacer()
        }
        
        // Price information
        VStack(alignment: .leading, spacing: 2) {
          Text(property.formattedPrice)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.primary)
          
          if let note = property.latestNote {
            Text(note.text)
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
        
        // Tags flow layout - show all tags below price
        if !tagsForProperty.isEmpty {
          TagFlowLayout(tags: tagsForProperty.sorted(by: { $0.name < $1.name }))
            .padding(.top, 4)
        }
      }
    }
    .padding(.vertical, 8)
    .contentShape(Rectangle())
  }
  
  private var tagsForProperty: [PropertyTag] {
    allTags.filter { tag in
      guard let tagId = tag.id else { return false }
      return property.tagIds.contains(tagId)
    }
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
      property: Property.sampleData[0],
      isSelected: false,
      onSelectionChanged: { _ in }
    )
    PropertyListRowView(
      property: Property.sampleData[1],
      isSelected: true,
      onSelectionChanged: { _ in }
    )
  }
}
