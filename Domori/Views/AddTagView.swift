import SwiftUI
import FirebaseFirestore

struct AddTagView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.firestore) private var firestore
  @FirestoreQuery(collectionPath: FirestoreCollection.tags.rawValue) private var allTags: [PropertyTag]
  
  let property: Property
  
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
      // If the tag has no id yet, we include it.
      guard let id = tag.id else {
        return true
      }
      // Otherwise include it only if its id isn’t already in the listing’s tagIds
      return !property.tagIds.contains(id)
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
    var updatedProperty = property
    Task {
      do {
        let newTagRef = try await firestore.setTag(newTag)
        updatedProperty.tagIds.append(newTagRef.documentID)
        _ = try await firestore.setProperty(updatedProperty)
      } catch {
        print("Error creating tag: \(error)")
      }
      
      newTagName = ""
      selectedRating = .good
      dismiss()
    }
  }
  
  private func addExistingTag(_ tag: PropertyTag) {
    var updatedProperty = property
    updatedProperty.tagIds.append(tag.id!)
    Task {
      do {
        _ = try await firestore.setProperty(updatedProperty)
      } catch {
        print("Error adding tag: \(error)")
      }
      dismiss()
    }
  }
}
