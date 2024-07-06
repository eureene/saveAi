// ContentView.swift

import SwiftUI
import FirebaseAuth

class AuthenticationViewModel: ObservableObject {
    @Published var isLoggedIn = false

    init() {
        Auth.auth().addStateDidChangeListener { _, user in
            self.isLoggedIn = user != nil
        }
    }
}
