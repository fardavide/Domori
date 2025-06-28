import SwiftUI

extension View {
  
  func previewQueries() -> some View {
    let userQuery = UserQuery()
    let workspaceQuery = WorkspaceQuery(
      userQuery: userQuery
    )
    let propertyQuery = PropertyQuery(
      userQuery: userQuery,
      workspaceQuery: workspaceQuery
    )
    let tagQuery = TagQuery(
      userQuery: userQuery,
      workspaceQuery: workspaceQuery
    )
    let workspaceJoinRequesttQuery = WorkspaceJoinRequestQuery(
      userQuery: userQuery,
      workspaceQuery: workspaceQuery
    )
    return self
      .environment(propertyQuery)
      .environment(tagQuery)
      .environment(userQuery)
      .environment(workspaceQuery)
      .environment(workspaceJoinRequesttQuery)
  }
}
