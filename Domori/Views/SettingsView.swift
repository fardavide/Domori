import SwiftUI

struct SettingsView: View {
    @AppStorage("showFavoritesFirst") private var showFavoritesFirst = false
    @AppStorage("enableCloudSync") private var enableCloudSync = true
    @AppStorage("enableNotifications") private var enableNotifications = true
    
    var body: some View {
        TabView {
            // General tab
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Locale & Regional Settings")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Currency:")
                            Spacer()
                            Text(Locale.current.currency?.identifier ?? "USD")
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Text("Size Unit:")
                            Spacer()
                            Text(Locale.current.usesMetricSystem ? "Square Meters (m²)" : "Square Feet (sq ft)")
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Text("Region:")
                            Spacer()
                            Text(Locale.current.region?.identifier ?? "Unknown")
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Text("Language:")
                            Spacer()
                            Text(Locale.current.language.languageCode?.identifier ?? "Unknown")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .font(.subheadline)
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Text("These settings are automatically detected from your device's regional preferences.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Display")
                        .font(.headline)
                    
                    Toggle("Show favorites first in list", isOn: $showFavoritesFirst)
                        .help("Display favorite properties at the top of the list")
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sync & Storage")
                        .font(.headline)
                    
                    Toggle("Enable iCloud sync", isOn: $enableCloudSync)
                        .help("Sync your properties across all your devices using iCloud")
                    
                    if enableCloudSync {
                        Text("Your properties will be automatically synced across all devices signed in to the same Apple ID.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Notifications")
                        .font(.headline)
                    
                    Toggle("Enable notifications", isOn: $enableNotifications)
                        .help("Get notified about important updates")
                }
                
                Spacer()
            }
            .padding()
            .tabItem {
                Label("General", systemImage: "gear")
            }
            
            // About tab
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("About Domori")
                        .font(.headline)
                    
                    Text("A modern property listing management app for iPhone, iPad, and Mac.")
                        .font(.body)
                    
                    Text("Version 1.0")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Features")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Save and organize property listings")
                        Text("• Add photos and categorized notes")
                        Text("• Compare properties side-by-side")
                        Text("• Custom tags and ratings")
                        Text("• iCloud sync across devices")
                        Text("• Automatic locale-based formatting")
                        Text("• Modern SwiftUI interface")
                    }
                    .font(.body)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Internationalization")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Automatic currency detection")
                        Text("• Metric/Imperial unit adaptation")
                        Text("• Regional price and size formatting")
                        Text("• Locale-aware number formatting")
                    }
                    .font(.body)
                    .foregroundStyle(.secondary)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Technologies")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• SwiftUI for modern interface")
                        Text("• SwiftData for local storage")
                        Text("• CloudKit for iCloud sync")
                        Text("• Swift 6.0 language features")
                        Text("• Multiplatform (iOS, iPadOS, macOS)")
                        Text("• Foundation localization APIs")
                    }
                    .font(.body)
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .tabItem {
                Label("About", systemImage: "info.circle")
            }
        }
        .frame(width: 500, height: 400)
    }
}

#Preview {
    SettingsView()
} 