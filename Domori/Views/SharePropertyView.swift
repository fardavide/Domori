import SwiftUI
import SwiftData

struct SharePropertyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var userManager = UserManager.shared
    
    @Bindable var property: PropertyListing
    
    @Query private var workspaces: [SharedWorkspace]
    @State private var selectedWorkspace: SharedWorkspace?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Property Preview
                VStack(alignment: .leading, spacing: 12) {
                    Text("Share Property")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Image(systemName: property.propertyType.systemImage)
                            .foregroundColor(.blue)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(property.title)
                                .font(.headline)
                            
                            Text(property.location)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("\(property.formattedPrice) • \(property.formattedSize)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if let rating = property.propertyRating, rating != .none {
                            Circle()
                                .fill(Color(rating.color))
                                .frame(width: 16, height: 16)
                        }
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Workspace Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("Select Workspace")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if availableWorkspaces.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "folder.badge.plus")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            
                            Text("No workspaces available")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Create a workspace in the Collaboration tab to share properties with others")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 32)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(availableWorkspaces, id: \.id) { workspace in
                                    WorkspaceSelectionRow(
                                        workspace: workspace,
                                        isSelected: selectedWorkspace?.id == workspace.id
                                    ) {
                                        selectedWorkspace = workspace
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
                
                // Share Button
                if !availableWorkspaces.isEmpty {
                    Button(action: shareProperty) {
                        Text("Share Property")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedWorkspace != nil ? Color.blue : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(selectedWorkspace == nil)
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var availableWorkspaces: [SharedWorkspace] {
        guard let currentUser = userManager.currentUser else { return [] }
        
        return workspaces.filter { workspace in
            workspace.isActive && (
                workspace.ownerEmail == currentUser.email ||
                workspace.members?.contains { $0.email == currentUser.email } == true
            )
        }
    }
    
    private func shareProperty() {
        guard let workspace = selectedWorkspace else { return }
        
        property.workspace = workspace
        property.updatedDate = Date()
        workspace.updatedDate = Date()
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error sharing property: \(error)")
        }
    }
}

struct WorkspaceSelectionRow: View {
    let workspace: SharedWorkspace
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title3)
                
                Image(systemName: "folder.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(workspace.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Owner: \(workspace.ownerEmail)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(workspace.properties?.count ?? 0) properties • \(workspace.allParticipants.count) members")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    let container = try! ModelContainer(for: PropertyListing.self, SharedWorkspace.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let sampleProperty = PropertyListing.sampleData[0]
    
    SharePropertyView(property: sampleProperty)
        .modelContainer(container)
} 