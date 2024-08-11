//
//  MatchMateApp.swift
//  MatchMate
//

//

import SwiftUI

@main
struct MatchMateApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared

    var body: some Scene {
        WindowGroup {
            MatchView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    print("NetworkMonitor initialized with isConnected: \(networkMonitor.isConnected)")
                    if networkMonitor.isConnected {
                        persistenceController.fetchAndSaveMatches()
                    } else {
                        print("Offline mode: Using cached data only.")
                    }
                    
                    let storedMatchesCount = persistenceController.countStoredMatches()
                    print("Number of matches stored in Core Data: \(storedMatchesCount)")
                }
        }
    }
}
