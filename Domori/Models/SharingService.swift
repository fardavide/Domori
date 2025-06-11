import Foundation
import SwiftData
import CloudKit
import SwiftUI

// MARK: - Sharing Service
@MainActor
class SharingService: ObservableObject {
    static let shared = SharingService()
    
    @Published var isPreparingShare = false
    @Published var activeShare: CKShare?
    @Published var shareURL: URL?
    @Published var errorMessage: String?
    
    let container: CKContainer
    
    private init() {
        // Use the default container for the app's bundle identifier
        self.container = CKContainer.default()
    }
    
    /// Check if the user is signed into iCloud
    var isCloudKitAvailable: Bool {
        #if targetEnvironment(simulator)
        return true // For testing in simulator
        #else
        return FileManager.default.ubiquityIdentityToken != nil
        #endif
    }
    
    /// Creates a record, a share, and saves them both to CloudKit in a single atomic operation.
    /// Returns a fully saved and valid CKShare.
    func createAndSaveShare(for properties: [PropertyListing]) async throws -> CKShare {
        isPreparingShare = true
        errorMessage = nil
        
        defer {
            isPreparingShare = false
        }
        
        guard !properties.isEmpty else {
            throw SharingError.noPropertiesToShare
        }
        
        guard isCloudKitAvailable else {
            throw SharingError.cloudKitNotAvailable
        }

        // 1. Create a CKRecord and a CKShare in memory.
        let recordId = CKRecord.ID(recordName: "PropertyCollection-\(UUID().uuidString)")
        let record = CKRecord(recordType: "PropertyCollection", recordID: recordId)
        record["name"] = "Domori Property Listings" as CKRecordValue
        let propertyNames = properties.map { $0.title }.joined(separator: ", ")
        record["propertyNames"] = propertyNames as CKRecordValue
        
        let share = CKShare(rootRecord: record)
        share[CKShare.SystemFieldKey.title] = "My Domori Properties" as CKRecordValue

        // 2. Create a CKModifyRecordsOperation to save both records at once.
        let operation = CKModifyRecordsOperation(recordsToSave: [record, share], recordIDsToDelete: nil)
        operation.savePolicy = .ifServerRecordUnchanged
        
        print("▶️ Saving root record and share in a single operation...")
        
        // 3. Use a continuation to bridge the callback-based API to modern async/await.
        return try await withCheckedThrowingContinuation { continuation in
            operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                if let error = error as? CKError {
                    print("❌ Failed to save record and share: \(error)")
                    
                    // Handle specific CloudKit errors
                    switch error.code {
                    case .accountTemporarilyUnavailable:
                        continuation.resume(throwing: SharingError.iCloudAccountUnavailable)
                    case .notAuthenticated:
                        continuation.resume(throwing: SharingError.cloudKitNotAvailable)
                    case .partialFailure:
                        if let partialErrors = error.userInfo[CKPartialErrorsByItemIDKey] as? [CKRecord.ID: Error] {
                            let errorMessages = partialErrors.values.map { $0.localizedDescription }.joined(separator: ", ")
                            continuation.resume(throwing: SharingError.shareCreationFailed(errorMessages))
                        } else {
                            continuation.resume(throwing: error)
                        }
                    default:
                        continuation.resume(throwing: error)
                    }
                    return
                }
                
                guard let savedRecords = savedRecords,
                      let savedShare = savedRecords.first(where: { $0 is CKShare }) as? CKShare else {
                    print("❌ No share object found among saved records.")
                    continuation.resume(throwing: SharingError.shareCreationFailed("Could not retrieve saved share."))
                    return
                }
                
                print("✅ Successfully saved record and share.")
                continuation.resume(returning: savedShare)
            }
            
            self.container.privateCloudDatabase.add(operation)
        }
    }
    
    /// Stops sharing by deleting the share record from CloudKit.
    func stopSharing() async {
        guard let share = activeShare else { return }
        
        do {
            let _ = try await container.privateCloudDatabase.modifyRecords(saving: [], deleting: [share.recordID])
            self.activeShare = nil
            self.shareURL = nil
            self.errorMessage = nil
            print("🗑️ Stopped sharing successfully.")
        } catch let error as CKError {
            switch error.code {
            case .accountTemporarilyUnavailable:
                self.errorMessage = SharingError.iCloudAccountUnavailable.localizedDescription
            case .notAuthenticated:
                self.errorMessage = SharingError.cloudKitNotAvailable.localizedDescription
            default:
                self.errorMessage = "Failed to stop sharing: \(error.localizedDescription)"
            }
            print("❌ Failed to stop sharing: \(error)")
        } catch {
            self.errorMessage = "Failed to stop sharing: \(error.localizedDescription)"
            print("❌ Failed to stop sharing: \(error)")
        }
    }
    
    /// Accepts a share invitation from a URL.
    func acceptShare(from url: URL) async {
        do {
            let shareMetadata = try await container.shareMetadata(for: url)
            try await container.accept(shareMetadata)
            errorMessage = nil
            print("✅ Accepted share successfully.")
        } catch {
            errorMessage = "Failed to accept share: \(error.localizedDescription)"
            print("❌ Failed to accept share: \(error)")
        }
    }
    
    /// Resets the local sharing state, useful for debugging.
    func resetSharingState() {
        activeShare = nil
        shareURL = nil
        errorMessage = nil
        isPreparingShare = false
        print("🧹 Reset local sharing state.")
    }
}

// MARK: - Sharing Errors
enum SharingError: LocalizedError {
    case cloudKitNotAvailable
    case noPropertiesToShare
    case shareCreationFailed(String)
    case shareAcceptanceFailed(String)
    case iCloudAccountUnavailable
    
    var errorDescription: String? {
        switch self {
        case .cloudKitNotAvailable:
            return "iCloud is not available. Please sign in to iCloud in Settings."
        case .noPropertiesToShare:
            return "There are no properties to share."
        case .shareCreationFailed(let message):
            return "Failed to create share: \(message)"
        case .shareAcceptanceFailed(let message):
            return "Failed to accept share: \(message)"
        case .iCloudAccountUnavailable:
            return "iCloud account is temporarily unavailable. Please check your iCloud settings and try again."
        }
    }
}

// MARK: - Main Sharing View
struct SharingView: View {
    @StateObject private var sharingService = SharingService.shared
    @Environment(\.modelContext) private var modelContext
    @Query private var allProperties: [PropertyListing]
    
    @State private var shareToPresent: CKShare?
    @State private var showingCloudSharingController = false
    @State private var showingActivitySheet = false
    @State private var linkCopied = false
    @State private var isProcessing = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .symbolEffect(.bounce, options: .repeating, value: isProcessing)
            
            Text("Share Your Property Listings")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Share your listings with family and friends. They can view and edit the shared properties based on the permissions you set.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            if !sharingService.isCloudKitAvailable {
                icloudNotAvailableWarning
            } else if let share = sharingService.activeShare, let url = sharingService.shareURL {
                sharingActiveView(share: share, url: url)
            } else {
                createShareView
            }
            
            if let errorMessage = sharingService.errorMessage {
                errorView(message: errorMessage)
            }
            
            Spacer()
            howItWorksView
        }
        .padding()
        .navigationTitle("Sharing")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingCloudSharingController) {
            if let share = shareToPresent {
                CloudSharingController(share: share, container: sharingService.container) { result in
                    handleSharingResult(result)
                }
            }
        }
        .sheet(isPresented: $showingActivitySheet) {
            if let url = sharingService.shareURL {
                ActivitySheet(activityItems: ["Check out these property listings from Domori!", url])
            }
        }
    }
    
    // MARK: Subviews
    private var icloudNotAvailableWarning: some View {
        VStack(spacing: 12) {
            Image(systemName: "icloud.slash")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            Text("iCloud Not Available")
                .font(.headline)
                .foregroundColor(.orange)
            Text("Please sign in to iCloud in Settings to use sharing features.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func sharingActiveView(share: CKShare, url: URL) -> some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Sharing is Active!")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            
            Button {
                self.shareToPresent = share
                self.showingCloudSharingController = true
            } label: {
                Label("Manage Share", systemImage: "person.2.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            
            HStack {
                Button {
                    UIPasteboard.general.string = url.absoluteString
                    withAnimation { linkCopied = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { 
                        withAnimation { linkCopied = false } 
                    }
                } label: {
                    Label(linkCopied ? "Copied!" : "Copy Link", 
                          systemImage: linkCopied ? "checkmark.circle.fill" : "link")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(linkCopied ? .green : .blue)
                
                Button {
                    showingActivitySheet = true
                } label: {
                    Label("Share via...", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            
            Button {
                Task {
                    isProcessing = true
                    await sharingService.stopSharing()
                    isProcessing = false
                }
            } label: {
                Label("Stop Sharing", systemImage: "xmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.red)
            
            #if DEBUG
            Button {
                sharingService.resetSharingState()
            } label: {
                Label("Reset (Debug)", systemImage: "arrow.counterclockwise")
                    .font(.caption)
            }
            .tint(.orange)
            #endif
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var createShareView: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "house.fill")
                    .foregroundColor(.blue)
                Text("\(allProperties.count) properties ready to share.")
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            if sharingService.isPreparingShare {
                ProgressView("Saving Share to iCloud...")
            } else {
                Button {
                    Task {
                        isProcessing = true
                        await createAndPresentShare()
                        isProcessing = false
                    }
                } label: {
                    Label("Create CloudKit Share", systemImage: "square.and.arrow.up.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(allProperties.isEmpty)
            }
            
            if allProperties.isEmpty {
                Text("Add some properties first before you can share them.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack {
            Text(message)
                .foregroundColor(.red)
                .font(.caption)
                .multilineTextAlignment(.center)
            Button {
                sharingService.errorMessage = nil
            } label: {
                Label("Clear Error", systemImage: "xmark.circle.fill")
                    .font(.caption)
            }
            .tint(.blue)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var howItWorksView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How CloudKit sharing works:")
                .font(.headline)
            VStack(alignment: .leading, spacing: 4) {
                Text("1. A share is saved to your private iCloud database.")
                Text("2. You can invite people or create a public link.")
                Text("3. Others can view/edit based on the permissions you set.")
                Text("4. All changes sync automatically via CloudKit.")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    // MARK: Methods
    private func createAndPresentShare() async {
        do {
            let savedShare = try await sharingService.createAndSaveShare(for: allProperties)
            sharingService.activeShare = savedShare
            sharingService.shareURL = savedShare.url
            self.shareToPresent = savedShare
            self.showingCloudSharingController = true
        } catch {
            print("❌ Failed to create and save share: \(error)")
            sharingService.errorMessage = error.localizedDescription
        }
    }
    
    private func handleSharingResult(_ result: Result<CKShare, Error>) {
        if case .failure(let error) = result {
            print("❌ Error after managing share: \(error)")
            sharingService.errorMessage = "Sharing Error: \(error.localizedDescription)"
        }
        self.showingCloudSharingController = false
    }
}

// MARK: - CloudKit Sharing Controller Representable
struct CloudSharingController: UIViewControllerRepresentable {
    let share: CKShare
    let container: CKContainer
    let completion: (Result<CKShare, Error>) -> Void
    
    func makeUIViewController(context: Context) -> UICloudSharingController {
        let sharingController = UICloudSharingController(share: share, container: container)
        sharingController.delegate = context.coordinator
        sharingController.availablePermissions = [.allowPublic, .allowPrivate, .allowReadOnly, .allowReadWrite]
        return sharingController
    }
    
    func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UICloudSharingControllerDelegate {
        let parent: CloudSharingController
        init(parent: CloudSharingController) { self.parent = parent }
        
        func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
            print("Coordinator: Failed to save share: \(error)")
            parent.completion(.failure(error))
        }
        
        func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
            print("Coordinator: Did save share.")
            // This is called on successful save or after user makes changes.
            guard let savedShare = csc.share else {
                let error = NSError(domain: "com.domori.sharing", code: 1, userInfo: [NSLocalizedDescriptionKey: "Saved share object was nil after saving."])
                parent.completion(.failure(error))
                return
            }
            parent.completion(.success(savedShare))
        }

        func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
            print("Coordinator: User stopped sharing.")
            // This is called when the user removes all people from a share.
            // We'll reset our local state to reflect this.
            DispatchQueue.main.async {
                self.parent.completion(.failure(SharingError.shareCreationFailed("Sharing was stopped by the user.")))
            }
        }
        
        func itemTitle(for csc: UICloudSharingController) -> String? {
            return "Domori Property Listings"
        }
    }
}

// MARK: - Activity Sheet for Native Sharing
struct ActivitySheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Share Acceptance View (Not part of this flow, but included for completeness)
struct ShareAcceptanceView: View {
    let shareURL: URL
    @StateObject private var sharingService = SharingService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var isAccepting = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.and.arrow.down").font(.system(size: 60)).foregroundColor(.blue)
            Text("CloudKit Share Invitation").font(.title2).fontWeight(.semibold)
            Text("You've been invited to access shared property listings.").multilineTextAlignment(.center).foregroundColor(.secondary)
            
            if isAccepting {
                ProgressView("Accepting Invitation...")
            } else {
                VStack(spacing: 12) {
                    Button("Accept Share") { acceptShare() }.buttonStyle(.borderedProminent)
                    Button("Decline") { dismiss() }.buttonStyle(.bordered)
                }
            }
            
            if let errorMessage = sharingService.errorMessage {
                Text(errorMessage).foregroundColor(.red).font(.caption)
            }
            Spacer()
        }.padding().navigationTitle("Share Invitation").navigationBarTitleDisplayMode(.inline)
    }
    
    private func acceptShare() {
        isAccepting = true
        Task {
            await sharingService.acceptShare(from: shareURL)
            await MainActor.run {
                isAccepting = false
                dismiss()
            }
        }
    }
}

