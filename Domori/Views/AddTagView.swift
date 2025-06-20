import SwiftUI
import SwiftData

struct AddTagView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var allTags: [PropertyTag]
    
    let listing: PropertyListing
    
    @State private var showingCreateTag = false
    @State private var newTagName = ""
    @State private var selectedRating: PropertyRating = .good
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Create new tag section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Create New Tag")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Name:")
                                    .fontWeight(.medium)
                                TextField("Enter tag name", text: $newTagName)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Rating:")
                                    .fontWeight(.medium)
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 8),
                                    GridItem(.flexible(), spacing: 8),
                                    GridItem(.flexible(), spacing: 8)
                                ], spacing: 8) {
                                    ForEach(PropertyRating.allCases, id: \.self) { rating in
                                        Button(action: {
                                            selectedRating = rating
                                        }) {
                                            VStack(spacing: 3) {
                                                Image(systemName: rating.systemImage)
                                                    .font(.title3)
                                                    .foregroundColor(PropertyTag(name: "", rating: rating).swiftUiColor)
                                                
                                                Text(rating.displayName)
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.primary)
                                                    .lineLimit(2)
                                                    .multilineTextAlignment(.center)
                                                    .minimumScaleFactor(0.8)
                                            }
                                            .frame(maxWidth: .infinity, minHeight: 50)
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 4)
                                            .background(ratingButtonBackground(for: rating))
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .accessibilityIdentifier("rating_\(rating.rawValue)")
                                        .accessibilityLabel(rating.displayName)
                                    }
                                }
                            }
                            
                            Button("Create Tag") {
                                createAndAddTag()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(newTagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Existing tags section
                    if !availableTags.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Add Existing Tag")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            FlowLayout(spacing: 8, data: availableTags) { tag in
                                TagChipView(tag: tag) {
                                    addExistingTag(tag)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .navigationTitle("Add Tags")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var availableTags: [PropertyTag] {
        allTags.filter { tag in
            !(listing.tags?.contains { $0.id == tag.id } ?? false)
        }
    }
    
    private func ratingButtonBackground(for rating: PropertyRating) -> some View {
        let isSelected = selectedRating == rating
        let tagColor = PropertyTag(name: "", rating: rating).swiftUiColor
        
        return RoundedRectangle(cornerRadius: 8)
            .fill(isSelected ? tagColor.opacity(0.15) : Color.clear)
            .stroke(isSelected ? tagColor : Color.gray.opacity(0.3), lineWidth: 1.5)
    }
    
    private func createAndAddTag() {
        let trimmedName = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let newTag = PropertyTag(name: trimmedName, rating: selectedRating)
        modelContext.insert(newTag)
        
        if listing.tags == nil {
            listing.tags = []
        }
        listing.tags?.append(newTag)
        try? modelContext.save()
        
        newTagName = ""
        selectedRating = .good
        dismiss()
    }
    
    private func addExistingTag(_ tag: PropertyTag) {
        if listing.tags == nil {
            listing.tags = []
        }
        listing.tags?.append(tag)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    let container = try! ModelContainer(for: PropertyListing.self, PropertyTag.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let sampleListing = PropertyListing.sampleData[0]
    
    return AddTagView(listing: sampleListing)
        .modelContainer(container)
} 