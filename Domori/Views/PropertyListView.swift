import SwiftUI
import SwiftData

struct PropertyListView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var allProperties: [PropertyListing]
  @State private var showingAddListing = false
  @State private var searchText = ""
  @State private var sortOption: SortOption = .dateAdded
  @State private var showingCompareView = false
  @State private var selectedListings: Set<PropertyListing> = []
  @State private var showingShareSheet = false
  @State private var sheetId = UUID() // Force fresh view instance
  
  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        
        
        // Search and sort controls
        VStack(alignment: .leading, spacing: 12) {
          HStack {
            Image(systemName: "magnifyingglass")
              .foregroundColor(.secondary)
            TextField("Search properties...", text: $searchText)
              .textFieldStyle(PlainTextFieldStyle())
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
#if os(iOS)
          .background(Color(.systemGray5))
#else
          .background(Color(NSColor.controlBackgroundColor))
#endif
          .cornerRadius(8)
          
          HStack {
            Text("Sort by:")
              .font(.subheadline)
              .foregroundColor(.secondary)
            
            Picker("Sort", selection: $sortOption) {
              ForEach(SortOption.allCases, id: \.self) { option in
                Text(option.displayName).tag(option)
              }
            }
            .pickerStyle(MenuPickerStyle())
            .accentColor(.primary)
            
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
          ForEach(filteredAndSortedListings, id: \.title) { listing in
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
        .listStyle(.plain)
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
            showingShareSheet = true
          } label: {
            Image(systemName: "square.and.arrow.up")
          }
          
          Button {
            sheetId = UUID() // Generate new ID for fresh view
            showingAddListing = true
          } label: {
            Image(systemName: "plus")
          }
        }
      }
      .sheet(isPresented: $showingAddListing) {
        AddPropertyView()
          .id(sheetId) // Force fresh view instance
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
      case .dateAdded:
        return first.createdDate > second.createdDate
      case .price:
        return first.price < second.price
      case .size:
        return first.size > second.size
      case .title:
        return first.title < second.title
      case .rating:
        // Sort by propertyRating, handling nil values
        let firstRating = first.propertyRating.rawValue
        let secondRating = second.propertyRating.rawValue
        return firstRating > secondRating
      }
    }
  }
  
  private func deleteProperty(_ listing: PropertyListing) {
    modelContext.delete(listing)
    selectedListings.remove(listing)
  }
}

enum SortOption: String, CaseIterable {
  case dateAdded = "Date Added"
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
