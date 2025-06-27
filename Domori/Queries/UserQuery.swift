import Combine
import FirebaseAuth
import SwiftUI

@Observable final class UserQuery {
  private var auth = Auth.auth()
  private var listener: AuthStateDidChangeListenerHandle?
  
  private(set) var current: User?
  private(set) var currentIdOrEmpty = ""
  
  let currentSubject = CurrentValueSubject<User?, Never>(nil)
  let currentIdOrEmptySubject = CurrentValueSubject<String, Never>("")
  
  init() {
    listener = auth.addStateDidChangeListener { auth, user in
      self.currentSubject.send(user)
      self.current = user
      let idOrEmpty = user?.uid ?? ""
      self.currentIdOrEmptySubject.send(idOrEmpty)
      self.currentIdOrEmpty = idOrEmpty
    }
  }
  
  deinit {
    auth.removeStateDidChangeListener(listener!)
  }
}
