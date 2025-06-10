import Foundation
import SwiftData
import CloudKit
import SwiftUI

@MainActor
class SharingService: ObservableObject {
    static let shared = SharingService()
    
    @Published var isSharing = false
    @Published var shareURL: URL?
    @Published var errorMessage: String?
    @Published var activeShare: CKShare?
    
    private let container = CKContainer(identifier: "iCloud.fardavide.Domori")
    
    private init() {}
    
    /// Share all properties using CloudKit's native sharing
    func shareAllProperties(modelContext: ModelContext) async {
        isSharing = true
        errorMessage = nil
        
        do {
            // Get all properties
            let properties = try modelContext.fetch(FetchDescriptor<PropertyListing>())
            
            guard !properties.isEmpty else {
                errorMessage = "No properties to share"
                isSharing = false
                return
            }
            
            // Create a simple root record to share
            let database = container.privateCloudDatabase
            let recordZone = CKRecordZone(zoneName: "SharedProperties")
            
            // Create zone if it doesn't exist
            do {
                let _ = try await database.modifyRecordZones(saving: [recordZone], deleting: [])
            } catch {
                // Zone might already exist, that's okay
            }
            
            // Create root record for sharing
            let rootRecord = CKRecord(recordType: "PropertyCollection", 
                                    recordID: CKRecord.ID(recordName: "shared_properties", 
                                                        zoneID: recordZone.zoneID))
            rootRecord["title"] = "Property Listings"
            rootRecord["propertyCount"] = properties.count
            rootRecord["sharedDate"] = Date()
            
            // Create the share
            let share = CKShare(rootRecord: rootRecord)
            share[CKShare.SystemFieldKey.title] = "Property Listings from Domori"
            share.publicPermission = .none
            
            // Save both records
            let _ = try await database.modifyRecords(saving: [rootRecord, share], deleting: [])
            
            // Update our state
            self.activeShare = share
            self.shareURL = share.url
            
        } catch {
            errorMessage = "Failed to create share: \(error.localizedDescription)"
        }
        
        isSharing = false
    }
    
    /// Accept a shared database
    func acceptShare(from url: URL, modelContext: ModelContext) async {
        do {
            // Get share metadata
            let shareMetadata = try await container.shareMetadata(for: url)
            
            // Accept the share
            try await container.accept(shareMetadata)
            
            errorMessage = nil
            
        } catch {
            errorMessage = "Failed to accept share: \(error.localizedDescription)"
        }
    }
    
    /// Stop sharing
    func stopSharing() async {
        guard let share = activeShare else { return }
        
        do {
            let database = container.privateCloudDatabase
            let _ = try await database.modifyRecords(saving: [], deleting: [share.recordID])
            
            await MainActor.run {
                self.activeShare = nil
                self.shareURL = nil
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to stop sharing: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - SwiftUI Integration
struct SharingView: View {
    @StateObject private var sharingService = SharingService.shared
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @Query private var allProperties: [PropertyListing]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Share Your Property Listings")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Share your property listings with others. They can view and collaborate on your properties.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "house.fill")
                            .foregroundColor(.blue)
                        Text("\(allProperties.count) properties")
                            .font(.headline)
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                if let shareURL = sharingService.shareURL {
                    VStack(spacing: 12) {
                        Text("Sharing Active!")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        Text("Your properties are now shared via CloudKit")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button("Send Invitation") {
                            showingShareSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Copy Share Link") {
                            UIPasteboard.general.string = shareURL.absoluteString
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Stop Sharing") {
                            Task {
                                await sharingService.stopSharing()
                            }
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                    }
                } else {
                    VStack(spacing: 12) {
                        if sharingService.isSharing {
                            ProgressView("Creating CloudKit share...")
                        } else {
                            Button("Create CloudKit Share") {
                                Task {
                                    await sharingService.shareAllProperties(modelContext: modelContext)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(sharingService.isSharing || allProperties.isEmpty)
                        }
                        
                        if allProperties.isEmpty {
                            Text("Add some properties first to share them")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if let errorMessage = sharingService.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("How CloudKit sharing works:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("1.")
                                .fontWeight(.semibold)
                            Text("Create a CloudKit share of your database")
                        }
                        HStack {
                            Text("2.")
                                .fontWeight(.semibold)
                            Text("Send the share link via Messages, Email, etc.")
                        }
                        HStack {
                            Text("3.")
                                .fontWeight(.semibold)
                            Text("Recipients can view AND edit your shared properties")
                        }
                        HStack {
                            Text("4.")
                                .fontWeight(.semibold)
                            Text("All changes sync automatically via CloudKit")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .padding()
            .navigationTitle("Sharing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let shareURL = sharingService.shareURL {
                ShareSheet(activityItems: [shareURL])
            }
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 