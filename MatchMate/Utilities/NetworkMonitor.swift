//
//  NetworkMonitor.swift
//  MatchMate
//

//

import Network
import Combine

enum NetworkError: Error {
    case noInternetConnection
    case connectionLost
}

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    private var monitor: NWPathMonitor
    private var queue = DispatchQueue(label: "NetworkMonitor")

    @Published var isConnected: Bool = true

    private init() {
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = (path.status == .satisfied)
                print("Network status updated: \(self?.isConnected == true ? "Connected" : "Not Connected")")
            }
        }
        monitor.start(queue: queue)
    }
}


private func handleError(_ error: NetworkError) {
    // Handle different network errors here
    switch error {
    case .noInternetConnection:
        print("No internet connection. Please try again later.")
    case .connectionLost:
        print("Network connection lost. Trying to reconnect...")
    }
}
