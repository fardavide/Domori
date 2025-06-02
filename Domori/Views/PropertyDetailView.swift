import SwiftUI

struct PropertyDetailView: View {
    @Bindable var listing: PropertyListing
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    @State private var showingEditSheet = false
    @State private var showingPhotosPicker = false
    @State private var newNoteContent = ""
    @State private var newNoteCategory: NoteCategory = .general
    @State private var showingAddNote = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(listing.title)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(listing.location)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            // Display link if available
                            if let link = listing.link, !link.isEmpty {
                                Button(action: {
                                    if let url = URL(string: link) {
#if os(iOS)
                                        UIApplication.shared.open(url)
#else
                                        NSWorkspace.shared.open(url)
#endif
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "link")
                                        Text("View Listing")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        Spacer()
                        
                        // Color-based rating
                        if let propertyRating = listing.propertyRating, propertyRating != .none {
                            HStack(spacing: 6) {
                                Image(systemName: propertyRating.systemImage)
                                    .foregroundColor(Color(propertyRating.color))
                                    .font(.title2)
                                Text(propertyRating.displayName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(propertyRating.color))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(propertyRating.color).opacity(0.1))
                            .cornerRadius(16)
                        }
                    }
                    
                    // Key metrics
                    HStack(spacing: 24) {
                        VStack(alignment: .leading) {
                            Text("Price")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(listing.formattedPrice)
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Size")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(listing.formattedSize)
                                .font(.title3)
                                .fontWeight(.medium)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Type")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Label(listing.propertyType.rawValue, systemImage: listing.propertyType.systemImage)
                                .font(.title3)
                                .fontWeight(.medium)
                        }
                    }
                    
                    // Bed/Bath info and price per unit
                    HStack(spacing: 24) {
                        if listing.bedrooms > 0 {
                            Label("\(listing.bedrooms) bed", systemImage: "bed.double")
                        }
                        Label("\(listing.bathroomText) bath", systemImage: "shower")
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Price per unit")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(listing.formattedPricePerUnit)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding()
                .background(systemBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                
                // Tags
                if !listing.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                            ForEach(listing.tags, id: \.name) { tag in
                                Text(tag.name)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(tag.color.rawValue).opacity(0.2))
                                    .foregroundStyle(Color(tag.color.rawValue))
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                        }
                    }
                    .padding()
                    .background(systemBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                }
                
                // Tabbed Content
                VStack(spacing: 0) {
                    // Tab selector
                    HStack {
                        ForEach(Array(["Overview", "Notes", "Photos"].enumerated()), id: \.offset) { index, title in
                            Button {
                                selectedTab = index
                            } label: {
                                Text(title)
                                    .font(.subheadline)
                                    .fontWeight(selectedTab == index ? .semibold : .regular)
                                    .foregroundStyle(selectedTab == index ? .primary : .secondary)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(
                                        selectedTab == index ? Color.blue.opacity(0.1) : Color.clear
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Tab content
                    Group {
                        if selectedTab == 0 {
                            overviewTab
                        } else if selectedTab == 1 {
                            notesTab
                        } else {
                            photosTab
                        }
                    }
                    .padding()
                }
                .background(systemBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
            }
            .padding()
        }
        .navigationTitle("Property Details")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            AddPropertyView(listing: listing)
        }
        .sheet(isPresented: $showingAddNote) {
            addNoteSheet
        }
    }
    
    private var overviewTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !listing.notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(listing.notes)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Details")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                VStack(spacing: 4) {
                    detailRow("Created", value: listing.createdDate.formatted(date: .abbreviated, time: .omitted))
                    detailRow("Updated", value: listing.updatedDate.formatted(date: .abbreviated, time: .omitted))
                    detailRow("Property Type", value: listing.propertyType.rawValue)
                    detailRow("Bedrooms", value: "\(listing.bedrooms)")
                    detailRow("Bathrooms", value: listing.bathroomText)
                    detailRow("Size", value: listing.formattedSize)
                }
            }
        }
    }
    
    private var notesTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Notes")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Add Note") {
                    showingAddNote = true
                }
                .font(.caption)
            }
            
            if listing.propertyNotes.isEmpty {
                ContentUnavailableView(
                    "No Notes Yet",
                    systemImage: "note.text",
                    description: Text("Add notes about this property to remember important details")
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(listing.propertyNotes.sorted(by: { $0.createdDate > $1.createdDate }), id: \.content) { note in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Label(note.category.rawValue, systemImage: note.category.systemImage)
                                    .font(.caption)
                                    .foregroundStyle(Color(note.category.color))
                                
                                Spacer()
                                
                                Text(note.createdDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Text(note.content)
                                .font(.body)
                        }
                        .padding()
                        .background(secondarySystemBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
    }
    
    private var photosTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Photos")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Add Photos") {
                    showingPhotosPicker = true
                }
                .font(.caption)
            }
            
            if listing.photos.isEmpty {
                ContentUnavailableView(
                    "No Photos Yet",
                    systemImage: "photo",
                    description: Text("Add photos to remember important visual details about this property")
                )
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(listing.photos.sorted(by: { $0.photoType.sortOrder < $1.photoType.sortOrder }), id: \.createdDate) { photo in
                        VStack(alignment: .leading, spacing: 6) {
#if os(iOS)
                            if let uiImage = UIImage(data: photo.imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
#else
                            if let nsImage = NSImage(data: photo.imageData) {
                                Image(nsImage: nsImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
#endif
                            
                            Text(photo.photoType.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                            
                            if !photo.caption.isEmpty {
                                Text(photo.caption)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var addNoteSheet: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Picker("Category", selection: $newNoteCategory) {
                        ForEach(NoteCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.systemImage)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Note")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    TextEditor(text: $newNoteContent)
                        .frame(minHeight: 100)
                        .padding(8)
                        .background(secondarySystemBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Note")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingAddNote = false
                        newNoteContent = ""
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let note = PropertyNote(content: newNoteContent, category: newNoteCategory)
                        note.propertyListing = listing
                        listing.propertyNotes.append(note)
                        modelContext.insert(note)
                        
                        showingAddNote = false
                        newNoteContent = ""
                    }
                    .disabled(newNoteContent.isEmpty)
                }
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
    
    private var secondarySystemBackgroundColor: Color {
#if os(iOS)
        Color(.secondarySystemBackground)
#else
        Color(NSColor.separatorColor).opacity(0.2)
#endif
    }
}

#Preview {
    NavigationView {
        PropertyDetailView(listing: PropertyListing.sampleData[0])
    }
    .modelContainer(for: PropertyListing.self, inMemory: true)
} 