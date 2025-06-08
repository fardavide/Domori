import SwiftUI

struct AddPropertyView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var userManager = UserManager.shared
    
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
        if isEditing {
            // For editing, only require title and location (link is optional for legacy listings)
            return !title.isEmpty && !location.isEmpty
        } else {
            // For new listings, require title, location, and link
            return !title.isEmpty && !location.isEmpty && !link.isEmpty
        }
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
            TextField("Location", text: $location, axis: .vertical)
                .lineLimit(2...4)
            
            HStack {
                TextField("Property Link", text: $link)
                if !link.isEmpty && URL(string: link) != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .help(isEditing ? "Link is optional for existing properties" : "Link is required for new properties")
            
            if !isEditing && link.isEmpty {
                Text("Link is required for new listings")
                    .font(.caption)
                    .foregroundColor(.orange)
            } else if !link.isEmpty && URL(string: link) == nil {
                Text("Please enter a valid URL")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            TextField("Agent Contact (Phone)", text: $agentContact)
                .help("Optional phone number of the property agent")
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
            .disabled(!isValidForSaving)
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
            .disabled(!isValidForSaving)
        }
#endif
    }
    
    private func loadPropertyData(_ listing: PropertyListing) {
        title = listing.title
        location = listing.location
        link = listing.link ?? ""
        agentContact = listing.agentContact ?? ""
        price = listing.price
        size = listing.size
        bedrooms = listing.bedrooms
        bathrooms = listing.bathrooms
        propertyType = listing.propertyType
        rating = listing.propertyRating ?? .none
    }
    
    private func saveProperty() {
        if let listing = listing {
            // Update existing listing
            listing.title = title
            listing.location = location
            listing.link = link.isEmpty ? nil : link
            listing.agentContact = agentContact.isEmpty ? nil : agentContact
            listing.price = price
            listing.size = size
            listing.bedrooms = bedrooms
            listing.bathrooms = bathrooms
            listing.propertyType = propertyType
            listing.updateRating(rating)
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
            
            // Add to user's workspace
            if let currentUser = userManager.getCurrentUser(context: modelContext),
               let workspace = currentUser.primaryWorkspace {
                newListing.workspace = workspace
                if workspace.properties == nil {
                    workspace.properties = []
                }
                workspace.properties!.append(newListing)
                workspace.updatedDate = Date()
            }
            
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
}

#Preview {
    AddPropertyView()
        .modelContainer(for: PropertyListing.self, inMemory: true)
}

#Preview("Edit Mode") {
    AddPropertyView(listing: PropertyListing.sampleData[0])
        .modelContainer(for: PropertyListing.self, inMemory: true)
} 