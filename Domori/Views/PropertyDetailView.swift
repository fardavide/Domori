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
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text(listing.address)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Button {
                            listing.isFavorite.toggle()
                        } label: {
                            Image(systemName: listing.isFavorite ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundStyle(listing.isFavorite ? .red : .secondary)
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
                    
                    // Bed/Bath info
                    HStack(spacing: 24) {
                        Label("\(listing.bedrooms) bed", systemImage: "bed.double")
                        Label("\(listing.bathroomText) bath", systemImage: "shower")
                        
                        Spacer()
                        
                        if listing.rating > 0 {
                            HStack(spacing: 4) {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= Int(listing.rating) ? "star.fill" : "star")
                                        .foregroundStyle(star <= Int(listing.rating) ? .yellow : .gray.opacity(0.3))
                                        .font(.caption)
                                }
                                Text(String(format: "%.1f", listing.rating))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
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
                    .background(Color(.systemBackground))
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
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
            }
            .padding()
        }
        .navigationTitle("Property Details")
        .navigationBarTitleDisplayMode(.inline)
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
                        .background(Color(.secondarySystemBackground))
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
                            if let uiImage = UIImage(data: photo.imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
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
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Note")
            .navigationBarTitleDisplayMode(.inline)
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
}

#Preview {
    NavigationView {
        PropertyDetailView(listing: PropertyListing.sampleData[0])
    }
    .modelContainer(for: PropertyListing.self, inMemory: true)
} 