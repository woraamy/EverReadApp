import Foundation
import SwiftUI

class UserSession: ObservableObject {
    @Published var currentUser: User?
    @AppStorage("authToken") var token: String?
    @AppStorage("isLoggedIn") var storedLoginState: Bool = false

    var isLoggedIn: Bool {
        storedLoginState
    }

    func login(user: User, token: String) {
        self.currentUser = user
        self.token = token
        self.storedLoginState = true
    }

    func logout() {
        self.currentUser = nil
        self.token = nil
        self.storedLoginState = false
    }
}
