import SwiftUI
import SwiftData

struct PropertyListView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var allProperties: [PropertyListing]
  @State private var showingAddListing = false
  @State private var searchText = ""
  @State private var sortOption: SortOption = .creationDate
  @State private var showingCompareView = false
  @State private var selectedListings: Set<PropertyListing> = []
  @State private var showingShareSheet = false
  
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
            NavigationLink(destination: PropertyDetailView(listing: listing)) {
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
          
          if FeatureFlags.isShareEnabled {
            Button {
              showingShareSheet = true
            } label: {
              Image(systemName: "square.and.arrow.up")
            }
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
      .sheet(isPresented: $showingShareSheet) {
        SharingView()
      }
      
    }
  }
  
  private var filteredAndSortedListings: [PropertyListing] {
    // Filter by search text
    let filtered = allProperties.filter { listing in
      if searchText.isEmpty {
        return true
      }
      return listing.title.localizedCaseInsensitiveContains(searchText) ||
      listing.location.localizedCaseInsensitiveContains(searchText)
    }
    
    return filtered.sorted { first, second in
      switch sortOption {
      case .creationDate:
        return first.createdDate > second.createdDate
      case .editDate:
        return first.updatedDate > second.updatedDate
      case .price:
        return first.price < second.price
      case .size:
        return first.size > second.size
      case .title:
        return first.title < second.title
      case .rating:
        return first.propertyRating.rawValue > second.propertyRating.rawValue
      }
    }
  }
  
  private func deleteProperty(_ listing: PropertyListing) {
    modelContext.delete(listing)
    selectedListings.remove(listing)
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
    .modelContainer(for: [PropertyListing.self], inMemory: true)
}
