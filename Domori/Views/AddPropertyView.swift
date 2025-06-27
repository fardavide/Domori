import SwiftUI
import FirebaseCore

struct AddPropertyView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(PropertyQuery.self) private var propertyQuery
  
  // Edit mode
  var listing: Property?
  
  // Import mode - prefilled data from intent
  var importData: PropertyImportData?
  
  // Form fields
  @State private var title = ""
  @State private var location = ""
  @State private var link = ""
  @State private var agency = ""
  @State private var price: Double = 0
  @State private var size: Double = 0
  @State private var bedrooms = 0
  @State private var bathrooms: Double = 1.0
  @State private var type: PropertyType = .house
  @State private var rating: PropertyRating = .none
  
  private var isEditing: Bool {
    listing != nil
  }
  
  private var isImportMode: Bool {
    importData != nil
  }
  
  // Validation computed properties
  private var isValidForSaving: Bool {
    return !title.isEmpty && !location.isEmpty && !link.isEmpty
  }
  
  // Locale-aware formatters and labels
  private var currencyCode: String {
    Locale.current.currency?.identifier ?? "USD"
  }
  
  private var sizeUnitLabel: String {
    switch Locale.current.measurementSystem {
    case .metric: "m²"
    case .uk: "m²"
    case .us: "sq ft"
    default: "m²"
    }
  }
  
  var body: some View {
    NavigationView {
      Form {
        basicInformationSection
        detailsSection
        ratingSection
      }
      .navigationTitle(isEditing ? "Edit Property" : (isImportMode ? "Import Property" : "Add Property"))
      .toolbar {
        toolbarContent
      }
    }
    .onAppear {
      if let listing = listing {
        loadPropertyData(listing)
      } else if let importData = importData {
        loadImportData(importData)
      } else {
        // Reset form when creating a new property
        resetForm()
      }
    }
  }
  
  private var basicInformationSection: some View {
    Section("Basic Information") {
      TextField("Title (Required)", text: $title)
      #if os(iOS)
        .textInputAutocapitalization(.words)
      #endif
      
      TextField("Location (Required)", text: $location, axis: .vertical)
        .lineLimit(2...4)
      
      TextField("Link (Required)", text: $link)
      
      TextField("Agency", text: $agency)
        .textContentType(.organizationName)
      #if os(iOS)
        .keyboardType(.namePhonePad)
      #endif
    }
  }
  
  private var detailsSection: some View {
    Section("Details") {
      priceField
      sizeField
      propertyTypePicker
      bedroomsStepper
      bathroomsPicker
    }
  }
  
  private var priceField: some View {
    HStack {
      Text("Price (\(currencyCode))")
      Spacer()
      TextField("0", value: $price, format: .number)
        .multilineTextAlignment(.trailing)
#if os(iOS)
        .keyboardType(.decimalPad)
#endif
    }
  }
  
  private var sizeField: some View {
    HStack {
      Text("Size (\(sizeUnitLabel))")
      Spacer()
      TextField("0", value: $size, format: .number)
#if os(iOS)
        .keyboardType(.decimalPad)
        .multilineTextAlignment(.trailing)
#endif
    }
    .help(sizeUnitLabel)
  }
  
  private var propertyTypePicker: some View {
    Picker("Property Type", selection: $type) {
      ForEach(PropertyType.allCases, id: \.self) { type in
        Text(type.rawValue).tag(type)
      }
    }
  }
  
  private var bedroomsStepper: some View {
    Stepper("Bedrooms: \(bedrooms)", value: $bedrooms, in: 0...10)
  }
  
  private var bathroomsPicker: some View {
    Picker("Bathrooms", selection: $bathrooms) {
      ForEach([0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0], id: \.self) { count in
        Text(formatBathroomCount(count))
          .tag(count)
      }
    }
    .pickerStyle(.menu)
  }
  
  private func formatBathroomCount(_ count: Double) -> String {
    count.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(count))" : String(format: "%.1f", count)
  }
  
  private var ratingSection: some View {
    Section("Rating") {
      VStack(alignment: .leading, spacing: 12) {
        Text("How do you feel about this property?")
          .font(.subheadline)
          .foregroundColor(.secondary)
        
        LazyVGrid(columns: [
          GridItem(.flexible()),
          GridItem(.flexible())
        ], spacing: 12) {
          ForEach(PropertyRating.allCases, id: \.self) { ratingOption in
            ratingButton(for: ratingOption)
          }
        }
      }
    }
  }
  
  private func ratingButton(for ratingOption: PropertyRating) -> some View {
    Button(action: {
      rating = ratingOption
    }) {
      HStack(spacing: 8) {
        Image(systemName: ratingOption.systemImage)
          .foregroundColor(Color(ratingOption.color))
          .font(.title2)
        
        Text(ratingOption.displayName)
          .font(.subheadline)
          .foregroundColor(.primary)
        
        Spacer()
        
        if rating == ratingOption {
          Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.blue)
        }
      }
      .padding(12)
      .background(ratingBackground(for: ratingOption))
    }
    .buttonStyle(PlainButtonStyle())
  }
  
  private func ratingBackground(for ratingOption: PropertyRating) -> some View {
    let isSelected = rating == ratingOption
    let fillColor = isSelected ? Color(ratingOption.color).opacity(0.1) : systemGray6Color
    let strokeColor = isSelected ? Color(ratingOption.color).opacity(0.3) : Color.clear
    
    return RoundedRectangle(cornerRadius: 12)
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
  
  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .cancellationAction) {
      Button("Cancel") {
        dismiss()
      }
    }
    ToolbarItem(placement: .primaryAction) {
      Button(isEditing ? "Update" : (isImportMode ? "Import" : "Save")) {
        saveProperty()
      }
      .disabled(!isValidForSaving)
    }
  }
  
  private func loadPropertyData(_ listing: Property) {
    title = listing.title
    location = listing.location
    link = listing.link
    agency = listing.agency ?? ""
    price = listing.price
    size = listing.size
    bedrooms = listing.bedrooms
    bathrooms = listing.bathrooms
    type = listing.type
    rating = listing.rating
  }
  
  private func loadImportData(_ importData: PropertyImportData) {
    title = importData.title
    location = importData.location
    link = importData.link
    agency = importData.agency
    price = importData.price
    size = importData.size
    bedrooms = importData.bedrooms
    bathrooms = importData.bathrooms
    type = importData.type
    rating = .none // Default rating for imported properties
  }
  
  private func saveProperty() {
    if var property = listing {
      // Update existing listing
      property.title = title
      property.location = location
      property.link = link
      property.agency = agency.isEmpty ? nil : agency
      property.price = price
      property.size = size
      property.bedrooms = bedrooms
      property.bathrooms = bathrooms
      property.type = type
      property.rating = rating
      property.updatedDate = Timestamp()
      
      Task {
        do {
          _ = try await propertyQuery.set(property)
        } catch {
          print("Error updating property: \(error)")
        }
      }
      
    } else {
      let newProperty = Property(
        title: title,
        location: location,
        link: link,
        agency: agency.isEmpty ? nil : agency,
        price: price,
        size: size,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        type: type,
        rating: rating
      )
      
      Task {
        do {
          _ = try await propertyQuery.set(newProperty)
        } catch {
          print("Error creating property: \(error)")
        }
      }
    }
    
    dismiss()
  }
  
  private func resetForm() {
    title = ""
    location = ""
    link = ""
    agency = ""
    price = 0
    size = 0
    bedrooms = 0
    bathrooms = 1.0
    type = .house
    rating = .none
  }
}

#Preview {
  AddPropertyView()
}

#Preview("Edit Mode") {
  AddPropertyView(listing: Property.sampleData[0])
}
