import SwiftData

final class PreviewContainer {
  
  @MainActor
  static func with(
    properties: [PropertyListing],
    for user: User,
  ) -> ModelContainer {
    let config = ModelConfiguration(
      schema: DomoriApp.schema,
      isStoredInMemoryOnly: true
    )
    let container = try! ModelContainer(
      for: DomoriApp.schema,
      configurations: config
    )
    let context = container.mainContext
    
    context.insert(user)
    let workspace = user.createPersonalWorkspace(context: context)
    
    for property in properties {
      workspace.addProperty(property, context: context)
    }
    
    try! context.save()
    return container
  }
}
