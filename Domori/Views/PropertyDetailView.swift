import SwiftUI
import FirebaseFirestore

struct PropertyDetailView: View {
  @State var property: Property
  @Environment(\.firestore) private var firestore
  @Environment(\.openURL) private var openURL
  @State private var showingEditSheet = false
  @State private var showingAddTagSheet = false
  @State private var showingNewNoteSheet = false
  @State private var newNote: String?
  
  @FirestoreQuery(collectionPath: FirestoreCollection.properties.rawValue) private var allProperties: [Property]
  @FirestoreQuery(collectionPath: FirestoreCollection.tags.rawValue) private var allTags: [PropertyTag]
  
  private var propertyTags: [PropertyTag] {
    allTags.filter { tag in
      guard let tagId = tag.id else { return false }
      return property.tagIds.contains(tagId)
    }
  }
  
  var basicInfoSection: some View {
    Section {
      VStack(alignment: .leading, spacing: 12) {
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text(property.title)
              .font(.title2)
              .fontWeight(.semibold)
            
            Text(property.location)
              .font(.subheadline)
              .foregroundStyle(.secondary)
            
            // Display link if available
            if !property.link.isEmpty {
              Button(action: {
                if let url = URL(string: property.link) {
                  openURL(url)
                }
              }) {
                HStack(spacing: 4) {
                  Image(systemName: "link")
                  Text("View Listing")
                }
                .font(.caption)
                .foregroundColor(.blue)
              }
            }
          }
          
          Spacer()
          
          VStack(alignment: .trailing) {
            Text(property.formattedPrice)
              .font(.title2)
              .fontWeight(.bold)
              .foregroundColor(.primary)
          }
        }
        
        Divider()
        
        // Property details row
        HStack(spacing: 24) {
          VStack(alignment: .leading) {
            Text("Size")
              .font(.caption)
              .foregroundStyle(.secondary)
            Text(property.formattedSize)
              .font(.title3)
              .fontWeight(.medium)
          }
          
          VStack(alignment: .leading) {
            Text("Type")
              .font(.caption)
              .foregroundStyle(.secondary)
            Label(property.type.rawValue, systemImage: property.type.systemImage)
              .font(.title3)
              .fontWeight(.medium)
          }
        }
        
        // Bed/Bath info and price per unit
        HStack(spacing: 24) {
          if property.bedrooms > 0 {
            Label(
              "\(property.bedrooms) \(property.bedrooms == 1 ? "bed" : "beds")",
              systemImage: "bed.double"
            )
          }
          Label(
            "\(property.bathroomText) \(Double(property.bathroomText) == 1.0 ? "bath" : "baths")",
            systemImage: "shower"
          )
          
          Spacer()
          
          VStack(alignment: .trailing) {
            Text("Price per unit")
              .font(.caption)
              .foregroundStyle(.secondary)
            Text(property.formattedPricePerUnit)
              .font(.subheadline)
              .fontWeight(.medium)
          }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
      }
    }
  }
  
  func contactSection(agentContact: String) -> some View {
    Section("Agent Contact") {
      Button(action: {
        // Format phone number for dialing
        let phoneNumber = agentContact.replacingOccurrences(of: " ", with: "")
          .replacingOccurrences(of: "-", with: "")
          .replacingOccurrences(of: "(", with: "")
          .replacingOccurrences(of: ")", with: "")
        
        if let url = URL(string: "tel:\(phoneNumber)") {
#if os(iOS)
          UIApplication.shared.open(url)
#endif
        }
      }) {
        VStack(alignment: .leading) {
          
          HStack(spacing: 12) {
            Image(systemName: "phone.fill")
              .foregroundColor(.green)
              .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
              Text("Phone Number")
                .font(.caption)
                .foregroundStyle(.secondary)
              
              Text(agentContact)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.blue)
            }
            
          }
        }
      }
    }
    .buttonStyle(PlainButtonStyle())
    .contextMenu {
      Button(action: {
        // Copy to clipboard
#if os(iOS)
        UIPasteboard.general.string = agentContact
#else
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(agentContact, forType: .string)
#endif
      }) {
        Label("Copy Phone Number", systemImage: "doc.on.doc")
      }
      
      Button(action: {
        // Format phone number for dialing
        let phoneNumber = agentContact.replacingOccurrences(of: " ", with: "")
          .replacingOccurrences(of: "-", with: "")
          .replacingOccurrences(of: "(", with: "")
          .replacingOccurrences(of: ")", with: "")
        
        if let url = URL(string: "tel:\(phoneNumber)") {
#if os(iOS)
          UIApplication.shared.open(url)
#endif
        }
      }) {
        Label("Call", systemImage: "phone")
      }
    }
  }
  
  var moreInfoSection: some View {
    Section("Property Information") {
      VStack(alignment: .leading, spacing: 16) {
        Text("Property Information")
          .font(.headline)
          .fontWeight(.semibold)
        
        VStack(spacing: 8) {
          detailRow("Created", value: property.createdDate?.formatted(date: .abbreviated, time: .shortened) ?? "Unknown")
          detailRow("Updated", value: property.updatedDate?.formatted(date: .abbreviated, time: .shortened) ?? "Unknown")
          detailRow("Property Type", value: property.type.rawValue)
          detailRow("Bedrooms", value: "\(property.bedrooms)")
          detailRow("Bathrooms", value: property.bathroomText)
          detailRow("Size", value: property.formattedSize)
        }
      }
    }
  }
  
  var notesSection: some View {
    Section {
      let notes = property.notes ?? []
      if !notes.isEmpty {
        ForEach(notes) { note in
          VStack {
            Text(note.text)
            Text("\(note.date.formatted(date: .abbreviated, time: .shortened))")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }
      } else {
        VStack(alignment: .leading, spacing: 8) {
          Text("No notes added")
            .font(.subheadline)
            .foregroundStyle(.secondary)
          
          Text("Tap 'New note' to organize this property")
            .font(.caption)
            .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    } header: {
      HStack {
        Text("Notes")
        Spacer()
        Button("New note") {
          showingNewNoteSheet = true
        }
      }
    }
  }
  
  var ratingSection: some View {
    Section("Rating") {
      InlineRatingPicker(
        selectedRating: Binding(
          get: { property.rating },
          set: { newRating in
            updateRating(newRating)
          }
        )
      )
    }
  }
  
  var tagsSection: some View {
    Section {
      if !propertyTags.isEmpty {
        // Full width flow layout for tags
        VStack(alignment: .leading, spacing: 8) {
          FlowLayout(spacing: 8, data: propertyTags.sorted(by: { $0.name < $1.name })) { tag in
            TagChipView(tag: tag) {
              // Remove tag when tapped
              removeTag(tag)
            }
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      } else {
        VStack(alignment: .leading, spacing: 8) {
          Text("No tags added")
            .font(.subheadline)
            .foregroundStyle(.secondary)
          
          Text("Tap 'Add tag' to organize this property")
            .font(.caption)
            .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    } header: {
      HStack {
        Text("Tags")
        Spacer()
        Button("Add tag") {
          showingAddTagSheet = true
        }
      }
    }
  }
  
  var sectionSeparator: some View {
    Rectangle()
      .fill(Color(.secondaryLabel))
      .frame(height: 1)
  }
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
      
        basicInfoSection
        sectionSeparator
        
        notesSection
        sectionSeparator
        
        tagsSection
        sectionSeparator
        
        ratingSection
        sectionSeparator
       
        if let agentContact = property.agentContact, !agentContact.isEmpty {
          contactSection(agentContact: agentContact)
          sectionSeparator
        }
        
        moreInfoSection
      }
      .padding()
    }
    .navigationTitle("Property Details")
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button("Edit") {
          showingEditSheet = true
        }
      }
    }
    .sheet(isPresented: $showingEditSheet) {
      AddPropertyView(listing: property)
    }
    .sheet(isPresented: $showingAddTagSheet) {
      AddTagView(property: property)
    }
    .sheet(isPresented: $showingNewNoteSheet) {
      NewNoteView(property: property)
        .presentationDetents([.fraction(0.3)])
    }
    .onChange(of: allProperties) {
      if let updatedProperty = $1.first(where: { $0.id == property.id }) {
        property = updatedProperty
      }
    }
  }
  
  private func detailRow(_ label: String, value: String) -> some View {
    HStack {
      Text(label)
        .foregroundStyle(.secondary)
      Spacer()
      Text(value)
        .fontWeight(.medium)
    }
    .font(.subheadline)
  }
  
  private var systemBackgroundColor: Color {
#if os(iOS)
    Color(.systemBackground)
#else
    Color(NSColor.controlBackgroundColor)
#endif
  }
  
  private func updateRating(_ newRating: PropertyRating) {
    var updatedProperty = property
    updatedProperty.rating = newRating
    updatedProperty.updatedDate = Timestamp()
    
    do {
      _ = try firestore.setProperty(updatedProperty)
      property = updatedProperty
    } catch {
      print("Error updating rating: \(error)")
    }
  }
  
  private func removeTag(_ tag: PropertyTag) {
    guard let tagId = tag.id else { return }
    var updatedProperty = property
    updatedProperty.tagIds.removeAll { $0 == tagId }
    updatedProperty.updatedDate = Timestamp()
    
    do {
      _ = try firestore.setProperty(updatedProperty)
      property = updatedProperty
    } catch {
      print("Error removing tag: \(error)")
    }
  }
}

// MARK: - Inline Rating Picker Component
struct InlineRatingPicker: View {
  @Binding var selectedRating: PropertyRating
  
  var body: some View {
    LazyVGrid(columns: [
      GridItem(.flexible()),
      GridItem(.flexible())
    ], spacing: 12) {
      ForEach(PropertyRating.allCases, id: \.self) { rating in
        ratingButton(for: rating)
      }
    }
  }
  
  private func ratingButton(for rating: PropertyRating) -> some View {
    Button(action: {
      selectedRating = rating
    }) {
      HStack {
        Image(systemName: rating.systemImage)
          .foregroundColor(Color(rating.color))
          .font(.callout)
        
        Text(rating.displayName)
          .font(.caption)
          .foregroundColor(.primary)
        
        Spacer()
        
        if selectedRating == rating {
          Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.blue)
            .font(.caption)
        }
      }
      .padding(8)
      .background(ratingBackground(for: rating))
    }
    .buttonStyle(PlainButtonStyle())
  }
  
  private func ratingBackground(for rating: PropertyRating) -> some View {
    let isSelected = selectedRating == rating
    let fillColor = isSelected ? Color(rating.color).opacity(0.1) : systemGray6Color
    let strokeColor = isSelected ? Color(rating.color).opacity(0.3) : Color.clear
    
    return RoundedRectangle(cornerRadius: 8)
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
}

#Preview {
  NavigationView {
    PropertyDetailView(property: Property.sampleData[0])
  }
}
