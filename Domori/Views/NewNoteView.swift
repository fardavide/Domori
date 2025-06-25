import SwiftUI
import FirebaseFirestore

struct NewNoteView: View {
  let property: Property
  @Environment(\.dismiss) private var dismiss
  @Environment(\.firestore) private var firestore
  
  @State private var showingCreateNote = false
  @State private var newNoteText = ""
  
  var body: some View {
    NavigationStack {
      TextField("Text of note", text: $newNoteText)
        .textFieldStyle(.roundedBorder)
        .lineLimit(5)
        .padding()
        .navigationTitle("Create Note")
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
              dismiss()
            }
          }
          if showingCreateNote {
            ToolbarItem(placement: .confirmationAction) {
              Button("Create") {
                createNote()
              }
            }
          }
        }
        .onChange(of: newNoteText) { _, newText in
          showingCreateNote = !newText.isEmpty
        }
    }
  }
  
  private func createNote() {
    var updatedProperty = property
    let note = PropertyNote(text: newNoteText)
    if updatedProperty.notes == nil {
      updatedProperty.notes = [note]
    } else {
      updatedProperty.notes?.append(note)
    }
    Task {
      if let _ = try? await firestore.setProperty(updatedProperty) {
        dismiss()
      } else {
        print("Error adding note")
      }
    }
  }
}

#Preview {
  NewNoteView(property: .sampleData[0])
}
