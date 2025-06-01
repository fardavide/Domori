import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var listings: [PropertyListing]
    @State private var showingAddListing = false
    @State private var searchText = ""
    @State private var sortOption: SortOption = .dateAdded
    @State private var showingCompareView = false
    @State private var selectedListings: Set<PropertyListing> = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search and sort controls
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search properties...", text: $searchText)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                    
                    Picker("Sort by", selection: $sortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .padding()
                
                Divider()
                
                // Listings list
                List(filteredListings, id: \.persistentModelID) { listing in
                    NavigationLink(destination: PropertyDetailView(listing: listing)) {
                        PropertyListRowView(listing: listing)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            deleteListing(listing)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            listing.isFavorite.toggle()
                        } label: {
                            Label(
                                listing.isFavorite ? "Unfavorite" : "Favorite",
                                systemImage: listing.isFavorite ? "heart.slash" : "heart"
                            )
                        }
                        .tint(.red)
                    }
                    .contextMenu {
                        Button {
                            selectedListings.insert(listing)
                        } label: {
                            Label("Select for Compare", systemImage: "rectangle.stack")
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Properties")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    if !selectedListings.isEmpty {
                        Button("Compare (\(selectedListings.count))") {
                            showingCompareView = true
                        }
                        .disabled(selectedListings.count < 2)
                        
                        Button("Clear") {
                            selectedListings.removeAll()
                        }
                    }
                    
                    Button {
                        showingAddListing = true
                    } label: {
                        Label("Add Property", systemImage: "plus")
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
    
    private var filteredListings: [PropertyListing] {
        let filtered = searchText.isEmpty ? listings : listings.filter { listing in
            listing.title.localizedCaseInsensitiveContains(searchText) ||
            listing.address.localizedCaseInsensitiveContains(searchText)
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
            case .favorites:
                if first.isFavorite != second.isFavorite {
                    return first.isFavorite
                }
                return first.createdDate > second.createdDate
            }
        }
    }
    
    private func deleteListing(_ listing: PropertyListing) {
        withAnimation {
            modelContext.delete(listing)
        }
    }
}

enum SortOption: String, CaseIterable {
    case dateAdded = "Date Added"
    case price = "Price"
    case size = "Size"
    case title = "Title"
    case favorites = "Favorites First"
}

#Preview {
    ContentView()
        .modelContainer(for: PropertyListing.self, inMemory: true)
} 