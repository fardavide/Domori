import SwiftUI
import CloudKit

struct ContentView: View {
    @EnvironmentObject private var urlHandler: UrlHandler
    
    var body: some View {
        MainTabView()
            .sheet(isPresented: $urlHandler.shouldShowImportView) {
                if let importData = urlHandler.importData {
                    AddPropertyView(importData: importData)
                }
            }
    }
}

#Preview {
    ContentView()
        .environmentObject(UrlHandler())
} 
