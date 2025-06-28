import Combine
import FirebaseAuth
import SwiftUI

@Observable final class UserQuery {
  private(set) var current: UserInfo?
  private(set) var currentIdOrEmpty = ""

  let currentSubject = CurrentValueSubject<UserInfo?, Never>(nil)
  let currentIdOrEmptySubject = CurrentValueSubject<String, Never>("")
  
  private var cancellable: AnyCancellable?
  
  init(authService: AuthService) {
    cancellable = authService.currentUserSubject
      .sink { user in
        let userId = user?.uid ?? ""
        self.currentSubject.send(user)
        self.current = user
        self.currentIdOrEmptySubject.send(userId)
        self.currentIdOrEmpty = userId
      }
  }
  
  deinit {
    cancellable?.cancel()
  }
}
