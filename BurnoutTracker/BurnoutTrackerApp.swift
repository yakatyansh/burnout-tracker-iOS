//
//  BurnoutTrackerApp.swift
//  BurnoutTracker
//
//  Created by Yash Katyan on 01/03/25.
//

import SwiftUI
import FirebaseCore
import SwiftData
import AuthenticationServices

@main
struct BurnoutTrackerApp: App {
    
        init() {
        FirebaseApp.configure()
    }

    
    @StateObject private var authManager = AuthManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if authManager.isSignedIn {
                ContentView()
                    .modelContainer(sharedModelContainer)
            } else {
                LoginView(authManager: authManager)
            }
        }
    }
}
