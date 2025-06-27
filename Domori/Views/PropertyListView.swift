import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct PropertyListView: View {
  @Environment(\.firestore) private var firestore
  
  @Environment(PropertyQuery.self) private var propertyQuery
  private var allProperties: [Property] { propertyQuery.all }
  
  @State private var sortOption: SortOption = .editDate
  @State private var searchText = ""
  @State private var showingAddProperty = false
  @State private var showingCompare = false
  @State private var selectedProperties: Set<Property> = []
  
  var body: some View {
    NavigationStack {
      List {
        ForEach(filteredAndSortedListings, id: \.id) { property in
          NavigationLink(destination: PropertyDetailView(property: property)) {
            PropertyListRowView(
              property: property,
              isSelected: selectedProperties.contains(property),
              onSelectionChanged: { isSelected in
                if isSelected {
                  selectedProperties.insert(property)
                } else {
                  selectedProperties.remove(property)
                }
              }
            )
          }
          .swipeActions(edge: .trailing) {
            Button("Delete", role: .destructive) {
              deleteProperty(property)
            }
          }
        }
      }
      .animation(.default, value: filteredAndSortedListings)
      .searchable(text: $searchText, prompt: "Search properties...")
      .navigationTitle("Properties")
      .toolbar {
        ToolbarItemGroup(placement: .principal) {
          
          if selectedProperties.count >= 2 {
            Button("Compare (\(selectedProperties.count))") {
              showingCompare = true
            }
            .font(.caption)
            .foregroundColor(.blue)
          } else {
            HStack {
              Text("Sort by:")
              
              Picker("Sort", selection: $sortOption) {
                ForEach(SortOption.allCases, id: \.self) { option in
                  Text(option.displayName).tag(option)
                }
              }
              .pickerStyle(.menu)
            }
          }
        }
        ToolbarItemGroup(placement: {
#if os(iOS)
          .navigationBarTrailing
#else
          .primaryAction
#endif
        }()) {
          if !selectedProperties.isEmpty {
            Button("Clear") {
              selectedProperties.removeAll()
            }
            .foregroundColor(.secondary)
          }
          
          Button {
            showingAddProperty = true
          } label: {
            Image(systemName: "plus")
          }
        }
      }
      .sheet(isPresented: $showingAddProperty) {
        AddPropertyView()
      }
      .sheet(isPresented: $showingCompare) {
        ComparePropertiesView(properties: Array(selectedProperties))
      }
    }
  }
  
  private var filteredAndSortedListings: [Property] {
    // Filter by search text
    let filtered = allProperties.filter { property in
      if searchText.isEmpty {
        return true
      }
      let agency = property.agency ?? ""
      let notes = String(property.notes?.map(\.text).joined(separator: " ") ?? "")
      let text = "\(property.title) \(property.location) \(agency) \(notes)"
      return text.localizedCaseInsensitiveContains(searchText)
    }
    
    return filtered.sorted { first, second in
      switch sortOption {
      case .creationDate:
        return first.createdDate?.dateValue() ?? Date.distantPast > second.createdDate?.dateValue() ?? Date.distantPast
      case .editDate:
        return first.updatedDate?.dateValue() ?? Date.distantPast > second.updatedDate?.dateValue() ?? Date.distantPast
      case .price:
        return first.price < second.price
      case .size:
        return first.size > second.size
      case .title:
        return first.title < second.title
      case .rating:
        return first.rating.rawValue > second.rating.rawValue
      }
    }
  }
  
  private func deleteProperty(_ property: Property) {
    guard let id = property.id else { return }
    Task {
      _ = try await firestore.deleteProperty(withId: id)
    }
  }
}

enum SortOption: String, CaseIterable {
  case creationDate = "Date Added"
  case editDate = "Last Modified"
  case price = "Price"
  case size = "Size"
  case title = "Title"
  case rating = "Rating"
  
  var displayName: String {
    return self.rawValue
  }
}

#Preview {
  PropertyListView()
}
