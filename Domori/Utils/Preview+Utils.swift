import SwiftData

final class PreviewContainer {
  
  @MainActor
  static func with(
    properties: [PropertyListing]
  ) -> ModelContainer {
    let schema = Schema([PropertyListing.self, PropertyTag.self])
    let config = ModelConfiguration(
      schema: schema,
      isStoredInMemoryOnly: true
    )
    let container = try! ModelContainer(
      for: schema,
      configurations: config
    )
    let context = container.mainContext
    
    for property in properties {
      context.insert(property)
    }
    
    try! context.save()
    return container
  }
}
