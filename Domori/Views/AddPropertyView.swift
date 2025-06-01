import SwiftUI

struct AddPropertyView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Edit mode
    var listing: PropertyListing?
    
    // Form fields
    @State private var title = ""
    @State private var address = ""
    @State private var price: Double = 0
    @State private var size: Double = 0
    @State private var bedrooms = 0
    @State private var bathrooms: Double = 1.0
    @State private var propertyType: PropertyType = .house
    @State private var rating: PropertyRating = .none
    @State private var notes = ""
    
    private var isEditing: Bool {
        listing != nil
    }
    
    // Locale-aware formatters and labels
    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }
    
    private var sizeUnitLabel: String {
        if #available(macOS 13.0, iOS 16.0, *) {
            return Locale.current.measurementSystem == .metric ? "Square meters (m²)" : "Square feet (sq ft)"
        } else {
            return Locale.current.usesMetricSystem ? "Square meters (m²)" : "Square feet (sq ft)"
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                basicInformationSection
                detailsSection
                ratingSection
                notesSection
            }
            .navigationTitle(isEditing ? "Edit Property" : "Add Property")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                toolbarContent
            }
        }
        .onAppear {
            if let listing = listing {
                loadPropertyData(listing)
            }
        }
    }
    
    private var basicInformationSection: some View {
        Section("Basic Information") {
            TextField("Property Title", text: $title)
            TextField("Address", text: $address, axis: .vertical)
                .lineLimit(2...4)
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
#if os(iOS)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
#endif
        }
    }
    
    private var sizeField: some View {
        HStack {
            Text("Size")
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
        HStack {
            Text("Bathrooms")
            Spacer()
            Picker("Bathrooms", selection: $bathrooms) {
                ForEach([0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0], id: \.self) { count in
                    Text(formatBathroomCount(count))
                        .tag(count)
                }
            }
            .pickerStyle(.menu)
        }
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
    
    private var notesSection: some View {
        Section("Notes") {
            TextField("Add any notes about this property...", text: $notes, axis: .vertical)
                .lineLimit(3...6)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
#if os(iOS)
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
                dismiss()
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(isEditing ? "Update" : "Save") {
                saveProperty()
            }
            .disabled(title.isEmpty || address.isEmpty)
        }
#else
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                dismiss()
            }
        }
        
        ToolbarItem(placement: .primaryAction) {
            Button(isEditing ? "Update" : "Save") {
                saveProperty()
            }
            .disabled(title.isEmpty || address.isEmpty)
        }
#endif
    }
    
    private func loadPropertyData(_ listing: PropertyListing) {
        title = listing.title
        address = listing.address
        price = listing.price
        size = listing.size
        bedrooms = listing.bedrooms
        bathrooms = listing.bathrooms
        propertyType = listing.propertyType
        rating = listing.propertyRating ?? .none
        notes = listing.notes
    }
    
    private func saveProperty() {
        if let listing = listing {
            // Update existing listing
            listing.title = title
            listing.address = address
            listing.price = price
            listing.size = size
            listing.bedrooms = bedrooms
            listing.bathrooms = bathrooms
            listing.propertyType = propertyType
            listing.updateRating(rating)
            listing.notes = notes
            listing.updatedDate = Date()
        } else {
            // Create new listing
            let newListing = PropertyListing(
                title: title,
                address: address,
                price: price,
                size: size,
                bedrooms: bedrooms,
                bathrooms: bathrooms,
                propertyType: propertyType,
                notes: notes,
                propertyRating: rating
            )
            modelContext.insert(newListing)
        }
        
        dismiss()
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