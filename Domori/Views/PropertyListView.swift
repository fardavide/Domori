import Foundation
import SwiftUI
import FirebaseFirestore

struct PropertyListView: View {
  @Environment(\.firestore) private var firestore
  @State private var sortOption: SortOption = .editDate
  @State private var searchText = ""
  @State private var showingAddListing = false
  @State private var showingCompareView = false
  @State private var selectedListings: Set<Property> = []
  
  @FirestoreQuery(
    collectionPath: FirestoreCollection.properties.rawValue,
    animation: .default,
  ) private var allProperties: [Property]
  
  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        
        VStack(alignment: .leading, spacing: 12) {
          HStack {
            Text("Sort by:")
            
            Picker("Sort", selection: $sortOption) {
              ForEach(SortOption.allCases, id: \.self) { option in
                Text(option.displayName).tag(option)
              }
            }
            .pickerStyle(.menu)
            
            Spacer()
            
            if selectedListings.count >= 2 {
              Button("Compare (\(selectedListings.count))") {
                showingCompareView = true
              }
              .font(.caption)
              .foregroundColor(.blue)
            }
          }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        
        // Property list
        List {
          ForEach(filteredAndSortedListings, id: \.id) { listing in
            NavigationLink(destination: PropertyDetailView(property: listing)) {
              PropertyListRowView(
                listing: listing,
                isSelected: selectedListings.contains(listing),
                onSelectionChanged: { isSelected in
                  if isSelected {
                    selectedListings.insert(listing)
                  } else {
                    selectedListings.remove(listing)
                  }
                }
              )
            }
            .swipeActions(edge: .trailing) {
              Button("Delete", role: .destructive) {
                deleteProperty(listing)
              }
            }
          }
        }
        .animation(.default, value: filteredAndSortedListings)
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: "Search properties...")
      }
      .navigationTitle("Properties")
      .toolbar {
        ToolbarItemGroup(placement: {
#if os(iOS)
          .navigationBarTrailing
#else
          .primaryAction
#endif
        }()) {
          if !selectedListings.isEmpty {
            Button("Clear") {
              selectedListings.removeAll()
            }
            .foregroundColor(.secondary)
          }
          
          Button {
            showingAddListing = true
          } label: {
            Image(systemName: "plus")
          }
        }
      }
      .sheet(isPresented: $showingAddListing) {
        AddPropertyView()
      }
      .sheet(isPresented: $showingCompareView) {
        ComparePropertiesView(listings: Array(selectedListings))
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
      return property.title.localizedCaseInsensitiveContains(searchText) ||
      property.location.localizedCaseInsensitiveContains(searchText) ||
      agency.localizedCaseInsensitiveContains(searchText)
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
  
  private func deleteProperty(_ listing: Property) {
    guard let id = listing.id else { return }
    firestore.collection(.properties).document(id).delete()
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
