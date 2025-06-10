import SwiftUI
import SwiftData

struct WorkspaceDetailView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @State private var userManager = UserManager.shared
  
  @Bindable var workspace: SharedWorkspace
  
  @State private var showingInviteUser = false
  @State private var showingLeaveConfirmation = false
  @State private var selectedProperty: PropertyListing?
  
  var body: some View {
    NavigationView {
      List {
        // Workspace Info
        Section {
          VStack(alignment: .leading, spacing: 12) {
            HStack {
              Image(systemName: "folder.fill")
                .foregroundColor(.orange)
                .font(.title2)
              
              VStack(alignment: .leading, spacing: 2) {
                Text("Placeholder")
                  .font(.title2)
                  .fontWeight(.semibold)
                
                Text("Created \(workspace.createdDate, format: .dateTime.day().month().year())")
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
              
              Spacer()
            }
            
            HStack {
              Label("\(workspace.properties?.count ?? 0)", systemImage: "house")
              Spacer()
              Label("\(workspace.allParticipants.count)", systemImage: "person.2")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
          }
          .padding(.vertical, 8)
        }
        
        // Properties
        Section("Shared Properties") {
          if let properties = workspace.properties, !properties.isEmpty {
            ForEach(properties, id: \.title) { property in
              PropertyRowView(property: property) {
                selectedProperty = property
              }
            }
            .onDelete(perform: removeProperties)
          } else {
            Text("No properties shared yet")
              .foregroundColor(.secondary)
              .font(.subheadline)
          }
          
          Button(action: {
            // Add existing properties to workspace
            showPropertyPicker()
          }) {
            Label("Add Properties to Workspace", systemImage: "plus.circle")
              .foregroundColor(.blue)
          }
        }
        
        // Members
        Section("Members") {
          // Owner
          if let owner = workspace.owner {
            UserRowView(user: owner, role: "Owner")
          }
          
          // Members
          if let members = workspace.members {
            ForEach(members, id: \.id) { member in
              UserRowView(user: member, role: "Member")
            }
            .onDelete(perform: removeMembers)
          }
          
          // Add member button (only for owner)
          if isCurrentUserOwner {
            Button(action: {
              showingInviteUser = true
            }) {
              Label("Invite Member", systemImage: "person.badge.plus")
                .foregroundColor(.blue)
            }
          }
        }
        
        // Pending Invitations (only for owner)
        if isCurrentUserOwner && hasPendingInvitations {
          Section("Pending Invitations") {
            ForEach(pendingInvitations, id: \.id) { invitation in
              VStack(alignment: .leading, spacing: 4) {
                Text(invitation.inviteeEmail)
                  .font(.subheadline)
                
                HStack {
                  Text("Sent \(invitation.createdDate, format: .dateTime.day().month())")
                    .font(.caption)
                    .foregroundColor(.secondary)
                  
                  Spacer()
                  
                  Button("Cancel") {
                    cancelInvitation(invitation)
                  }
                  .font(.caption)
                  .foregroundColor(.red)
                }
              }
            }
          }
        }
        
        // Actions
        Section {
          if !isCurrentUserOwner {
            Button("Leave Workspace") {
              showingLeaveConfirmation = true
            }
            .foregroundColor(.red)
          }
        }
      }
      .navigationTitle("Workspace")
      .toolbar {
#if os(iOS)
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Done") {
            dismiss()
          }
        }
#else
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") {
            dismiss()
          }
        }
#endif
      }
      .sheet(isPresented: $showingInviteUser) {
        InviteUserView(workspace: workspace)
      }
      .sheet(item: $selectedProperty) { property in
        PropertyDetailView(listing: property)
      }
      .confirmationDialog("Leave Workspace", isPresented: $showingLeaveConfirmation) {
        Button("Leave", role: .destructive) {
          leaveWorkspace()
        }
        Button("Cancel", role: .cancel) { }
      } message: {
        Text("Are you sure you want to leave this workspace? You will lose access to all shared properties.")
      }
    }
  }
  
  // MARK: - Computed Properties
  
  private var isCurrentUserOwner: Bool {
    guard let currentUser = userManager.getCurrentUser(context: modelContext) else { return false }
    return workspace.isUserOwner(currentUser)
  }
  
  private var pendingInvitations: [WorkspaceInvitation] {
    return workspace.invitations?.filter { $0.isActive } ?? []
  }
  
  private var hasPendingInvitations: Bool {
    return !pendingInvitations.isEmpty
  }
  
  // MARK: - Actions
  
  private func removeProperties(offsets: IndexSet) {
    guard let properties = workspace.properties else { return }
    
    for index in offsets {
      let property = properties[index]
      property.workspace = nil
    }
    
    workspace.updatedDate = Date()
    
    do {
      try modelContext.save()
    } catch {
      print("Error removing properties: \(error)")
    }
  }
  
  private func removeMembers(offsets: IndexSet) {
    guard isCurrentUserOwner,
          let members = workspace.members else { return }
    
    for index in offsets {
      let member = members[index]
      workspace.removeMember(member)
    }
    
    do {
      try modelContext.save()
    } catch {
      print("Error removing member: \(error)")
    }
  }
  
  private func cancelInvitation(_ invitation: WorkspaceInvitation) {
    invitation.cancel()
    
    do {
      try modelContext.save()
    } catch {
      print("Error cancelling invitation: \(error)")
    }
  }
  
  private func leaveWorkspace() {
    guard let currentUser = userManager.getCurrentUser(context: modelContext) else { return }
    
    workspace.removeMember(currentUser)
    
    do {
      try modelContext.save()
      dismiss()
    } catch {
      print("Error leaving workspace: \(error)")
    }
  }
  
  private func showPropertyPicker() {
    // This would typically present a sheet with a property picker
    // For now, we'll implement this as a placeholder
    print("Property picker not yet implemented")
  }
}

// MARK: - Supporting Views

struct PropertyRowView: View {
  let property: PropertyListing
  let onTap: () -> Void
  
  var body: some View {
    Button(action: onTap) {
      HStack {
        Image(systemName: property.propertyType.systemImage)
          .foregroundColor(.blue)
          .font(.title3)
        
        VStack(alignment: .leading, spacing: 2) {
          Text(property.title)
            .font(.headline)
            .foregroundColor(.primary)
          
          Text(property.location)
            .font(.caption)
            .foregroundColor(.secondary)
          
          Text("\(property.formattedPrice) • \(property.formattedSize)")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        
        Spacer()
        
        if property.propertyRating != .none {
          Circle()
            .fill(Color(property.propertyRating.color))
            .frame(width: 12, height: 12)
        }
      }
      .padding(.vertical, 4)
    }
    .buttonStyle(PlainButtonStyle())
  }
}

struct UserRowView: View {
  let user: User
  let role: String
  
  var body: some View {
    HStack {
      Image(systemName: "person.circle.fill")
        .foregroundColor(.blue)
        .font(.title3)
      
      VStack(alignment: .leading, spacing: 2) {
        Text(user.name)
          .font(.headline)
        
        Text(user.email)
          .font(.caption)
          .foregroundColor(.secondary)
      }
      
      Spacer()
      
      Text(role)
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.secondary.opacity(0.2))
        .cornerRadius(8)
    }
    .padding(.vertical, 2)
  }
}

#Preview {
  let container = try! ModelContainer(for: SharedWorkspace.self, User.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
  let sampleUser = User(name: "John Doe", email: "john@example.com")
  let sampleWorkspace = SharedWorkspace(owner: sampleUser)
  
  WorkspaceDetailView(workspace: sampleWorkspace)
    .modelContainer(container)
}
