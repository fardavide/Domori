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
    @State private var rating: Double = 0
    @State private var notes = ""
    @State private var isFavorite = false
    
    private var isEditing: Bool {
        listing != nil
    }
    
    // Locale-aware formatters and labels
    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }
    
    private var sizeUnit: String {
        Locale.current.usesMetricSystem ? "m²" : "sq ft"
    }
    
    private var sizeLabel: String {
        Locale.current.usesMetricSystem ? "Size (square meters)" : "Size (square feet)"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Property Title", text: $title)
                    
                    TextField("Address", text: $address, axis: .vertical)
                        .lineLimit(2...4)
                    
                    Picker("Property Type", selection: $propertyType) {
                        ForEach(PropertyType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.systemImage)
                                .tag(type)
                        }
                    }
                }
                
                Section("Details") {
                    HStack {
                        Text("Price")
                        Spacer()
                        TextField("Price", value: $price, format: .currency(code: currencyCode))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text(sizeLabel)
                        Spacer()
                        TextField("Size", value: $size, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text(sizeUnit)
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                    
                    Stepper("Bedrooms: \(bedrooms)", value: $bedrooms, in: 0...10)
                    
                    HStack {
                        Text("Bathrooms")
                        Spacer()
                        Picker("Bathrooms", selection: $bathrooms) {
                            ForEach(Array(stride(from: 0.5, through: 6.0, by: 0.5)), id: \.self) { value in
                                Text(value.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(value))" : String(format: "%.1f", value))
                                    .tag(value)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section("Rating & Notes") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rating")
                        
                        HStack {
                            ForEach(1...5, id: \.self) { star in
                                Button {
                                    rating = Double(star)
                                } label: {
                                    Image(systemName: star <= Int(rating) ? "star.fill" : "star")
                                        .foregroundStyle(star <= Int(rating) ? .yellow : .gray.opacity(0.3))
                                        .font(.title3)
                                }
                            }
                            
                            Spacer()
                            
                            if rating > 0 {
                                Button("Clear") {
                                    rating = 0
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Toggle("Favorite", isOn: $isFavorite)
                }
                
                if !isEditing {
                    Section {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.blue)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Locale Information")
                                    .font(.headline)
                                Text("Currency: \(Locale.current.currency?.identifier ?? "USD")")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("Size unit: \(sizeUnit)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Property" : "Add Property")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Update" : "Save") {
                        saveProperty()
                    }
                    .disabled(title.isEmpty || address.isEmpty || price <= 0 || size <= 0)
                }
            }
        }
        .onAppear {
            if let listing = listing {
                loadProperty(listing)
            }
        }
    }
    
    private func loadProperty(_ property: PropertyListing) {
        title = property.title
        address = property.address
        price = property.price
        size = property.size
        bedrooms = property.bedrooms
        bathrooms = property.bathrooms
        propertyType = property.propertyType
        rating = property.rating
        notes = property.notes
        isFavorite = property.isFavorite
    }
    
    private func saveProperty() {
        if let existingListing = listing {
            // Update existing property
            existingListing.title = title
            existingListing.address = address
            existingListing.price = price
            existingListing.size = size
            existingListing.bedrooms = bedrooms
            existingListing.bathrooms = bathrooms
            existingListing.propertyType = propertyType
            existingListing.rating = rating
            existingListing.notes = notes
            existingListing.isFavorite = isFavorite
            existingListing.updatedDate = Date()
        } else {
            // Create new property
            let newListing = PropertyListing(
                title: title,
                address: address,
                price: price,
                size: size,
                bedrooms: bedrooms,
                bathrooms: bathrooms,
                propertyType: propertyType,
                rating: rating,
                notes: notes,
                isFavorite: isFavorite
            )
            
            modelContext.insert(newListing)
        }
        
        dismiss()
    }
}

#Preview("Add Property") {
    AddPropertyView()
        .modelContainer(for: PropertyListing.self, inMemory: true)
}

#Preview("Edit Property") {
    AddPropertyView(listing: PropertyListing.sampleData[0])
        .modelContainer(for: PropertyListing.self, inMemory: true)
} 