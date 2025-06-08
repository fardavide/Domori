import SwiftUI
import SwiftData

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var allProperties: [PropertyListing]
  @Query private var allWorkspaces: [SharedWorkspace]
  @State private var userManager = UserManager.shared
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
  
  private var filteredAndSortedListings: [PropertyListing] {
    // Try to ensure user exists in database
    if userManager.isSignedIn, let userManagerUser = userManager.currentUser {
      ensureUserInDatabase(userManagerUser)
    }
    
    // Get current user and workspace
    guard let currentUser = userManager.getCurrentUser(context: modelContext) else {
      return []
    }
    
    guard let workspace = currentUser.primaryWorkspace else {
      return []
    }
    
    let workspaceProperties = workspace.properties ?? []
    
    // Filter by search text
    let filtered = workspaceProperties.filter { listing in
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
  

  
  private func getCurrentUserWorkspace() -> SharedWorkspace? {
    guard let currentUser = userManager.getCurrentUser(context: modelContext) else {
      return nil
    }
    return currentUser.primaryWorkspace
  }
  
  private func ensureUserInDatabase(_ userManagerUser: User) {
    // Check if user already exists in database
    let userEmail = userManagerUser.email
    let descriptor = FetchDescriptor<User>(
      predicate: #Predicate<User> { user in
        user.email == userEmail
      }
    )
    
    do {
      let existingUsers = try modelContext.fetch(descriptor)
      if existingUsers.isEmpty {
        // Create user in database
        let dbUser = User(name: userManagerUser.name, email: userManagerUser.email)
        dbUser.id = userManagerUser.id // Keep the same ID
        modelContext.insert(dbUser)
        try modelContext.save()
        
        // Create personal workspace for user
        dbUser.createPersonalWorkspace(context: modelContext)
        try modelContext.save()
      } else {
        // Ensure user has a personal workspace
        if let existingUser = existingUsers.first {
          existingUser.createPersonalWorkspace(context: modelContext)
          try modelContext.save()
        }
      }
    } catch {
      print("Error ensuring user in database: \(error.localizedDescription)")
    }
  }
}

enum SortOption: String, CaseIterable {
    case dateAdded = "Date Added"
    case price = "Price"
    case size = "Size"
    case title = "Title"
    case rating = "Rating"
    
    var displayName: String {
        switch self {
        case .dateAdded: return "Date Added"
        case .price: return "Price (Low to High)"
        case .size: return "Size (Large to Small)"
        case .title: return "Title (A-Z)"
        case .rating: return "Rating"
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: PropertyListing.self, inMemory: true)
} 
