import SwiftUI

struct AddPropertyView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  
  // Edit mode
  var listing: PropertyListing?
  
  // Form fields
  @State private var title = ""
  @State private var location = ""
  @State private var link = ""
  @State private var agentContact = ""
  @State private var price: Double = 0
  @State private var size: Double = 0
  @State private var bedrooms = 0
  @State private var bathrooms: Double = 1.0
  @State private var propertyType: PropertyType = .house
  @State private var rating: PropertyRating = .none
  
  private var isEditing: Bool {
    listing != nil
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
      .navigationTitle(isEditing ? "Edit Property" : "Add Property")
      .toolbar {
        toolbarContent
      }
    }
    .onAppear {
      if let listing = listing {
        loadPropertyData(listing)
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
      
      TextField("Agent Contact (Phone)", text: $agentContact)
        .textContentType(.telephoneNumber)
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
    Picker("Property Type", selection: $propertyType) {
      ForEach(PropertyType.allCases, id: \.self) { type in
        Label(type.rawValue, systemImage: type.systemImage)
          .tag(type)
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
      Button(isEditing ? "Update" : "Save") {
        saveProperty()
      }
      .disabled(!isValidForSaving)
    }
  }
  
  private func loadPropertyData(_ listing: PropertyListing) {
    title = listing.title
    location = listing.location
    link = listing.link
    agentContact = listing.agentContact ?? ""
    price = listing.price
    size = listing.size
    bedrooms = listing.bedrooms
    bathrooms = listing.bathrooms
    propertyType = listing.propertyType
    rating = listing.propertyRating
  }
  
  private func saveProperty() {
    if let listing = listing {
      // Update existing listing
      listing.title = title
      listing.location = location
      listing.link = link
      listing.agentContact = agentContact.isEmpty ? nil : agentContact
      listing.price = price
      listing.size = size
      listing.bedrooms = bedrooms
      listing.bathrooms = bathrooms
      listing.propertyType = propertyType
      listing.propertyRating = rating
      listing.updatedDate = Date()
    } else {
      // Create new listing and add to user's workspace
      let newListing = PropertyListing(
        title: title,
        location: location,
        link: link,
        agentContact: agentContact.isEmpty ? nil : agentContact,
        price: price,
        size: size,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        propertyType: propertyType,
        propertyRating: rating
      )
      
      modelContext.insert(newListing)
    }
    
    // Save changes to persist immediately
    do {
      try modelContext.save()
    } catch {
      print("Error saving property: \(error)")
    }
    
    dismiss()
  }
  
  private func resetForm() {
    title = ""
    location = ""
    link = ""
    agentContact = ""
    price = 0
    size = 0
    bedrooms = 0
    bathrooms = 1.0
    propertyType = .house
    rating = .none
  }
}

#Preview {
  AddPropertyView()
    .modelContainer(for: PropertyListing.self, inMemory: true)
}

#Preview("Edit Mode") {
  AddPropertyView(listing: PropertyListing.sampleData[0])
    .modelContainer(for: PropertyListing.self, inMemory: true)
}
