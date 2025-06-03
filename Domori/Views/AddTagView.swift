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
                                
                                HStack(spacing: 12) {
                                    ForEach(PropertyRating.allCases, id: \.self) { rating in
                                        Button(action: {
                                            selectedRating = rating
                                        }) {
                                            VStack(spacing: 4) {
                                                Image(systemName: rating.systemImage)
                                                    .font(.title2)
                                                    .foregroundColor(PropertyTag(name: "", rating: rating).swiftUiColor)
                                                
                                                Text(rating.displayName)
                                                    .font(.caption2)
                                                    .foregroundColor(.primary)
                                            }
                                            .padding(8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(selectedRating == rating ? 
                                                         PropertyTag(name: "", rating: rating).swiftUiColor.opacity(0.2) : 
                                                         Color.clear)
                                                    .stroke(selectedRating == rating ? 
                                                           PropertyTag(name: "", rating: rating).swiftUiColor : 
                                                           Color.gray.opacity(0.3), lineWidth: 1)
                                            )
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
                    .background(Color(.systemGray6))
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
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .navigationTitle("Add Tags")
            .navigationBarTitleDisplayMode(.inline)
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
            !listing.tags.contains { $0.id == tag.id }
        }
    }
    
    private func createAndAddTag() {
        let trimmedName = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let newTag = PropertyTag(name: trimmedName, rating: selectedRating)
        modelContext.insert(newTag)
        
        listing.tags.append(newTag)
        try? modelContext.save()
        
        newTagName = ""
        selectedRating = .good
        dismiss()
    }
    
    private func addExistingTag(_ tag: PropertyTag) {
        listing.tags.append(tag)
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