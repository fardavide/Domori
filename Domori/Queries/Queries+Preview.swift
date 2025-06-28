import SwiftUI

extension View {
  
  func previewQueries(
    authService: AuthService = .init()
  ) -> some View {
    let userQuery = UserQuery(
      authService: authService
    )
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
