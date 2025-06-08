import SwiftUI
import SwiftData

struct UserSignInView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var userManager = UserManager.shared
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var showingError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // App Logo/Icon
                VStack(spacing: 16) {
                    Image(systemName: "house.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Welcome to Domori")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Sign in to start managing your properties and collaborate with others")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Sign In Form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Information")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Name")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                TextField("Enter your name", text: $name)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Email")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                TextField("Enter your email", text: $email)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                            }
                        }
                    }
                    
                    Button(action: signIn) {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .disabled(!isValidInput)
                    .opacity(isValidInput ? 1.0 : 0.6)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Info Text
                VStack(spacing: 8) {
                    Text("Your information is stored locally and synced via iCloud")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text("Use the same email across devices to access your shared workspaces")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationBarHidden(true)
        }
        .alert("Sign In Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var isValidInput: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        email.contains("@") && email.contains(".")
    }
    
    private func signIn() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        guard isValidInput else {
            errorMessage = "Please enter a valid name and email address"
            showingError = true
            return
        }
        
        userManager.signIn(name: trimmedName, email: trimmedEmail, context: modelContext)
    }
}

#Preview {
    UserSignInView()
        .modelContainer(for: [PropertyListing.self, User.self], inMemory: true)
} 