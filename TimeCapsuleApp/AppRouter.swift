//
//  AppRouter.swift
//  TimeCapsuleApp
//
//  Created by Abraham May on 11/18/25.
//


import SwiftUI
import FirebaseAuth

class AppRouter: ObservableObject {
    @Published var route: Route = .loading

    enum Route {
        case loading      // During check
        case splash       // Logged in
        case login        // Logged out
    }

    init() {
        checkAuth()
    }

    func checkAuth() {
        if let _ = Auth.auth().currentUser {
            // User exists → show splash
            route = .splash
        } else {
            // No user → go straight to login (Timecap)
            route = .login
        }
    }
}
