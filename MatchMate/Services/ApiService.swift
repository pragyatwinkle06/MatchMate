
import Foundation
import Combine

class ApiService {
    static let shared = ApiService()
    @Published var matches: [Match] = []

    func fetchMatches(completion: @escaping (Result<[Match], Error>) -> Void) {
        guard let url = URL(string: "https://randomuser.me/api/?results=10") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            do {
                let decodedResponse = try JSONDecoder().decode(MatchResponse.self, from: data)
                self.matches = decodedResponse.results
                completion(.success(decodedResponse.results))
            } catch let error {
                                     
                                          print("Error parsing JSON: \(error)")
                                          print("Error parsing JSON: \(error.localizedDescription)")
                completion(.failure(error))
            }
            

        }.resume()
    }
    
    func updateMatchStatus(id: UUID, isAccepted: String?, completion: @escaping (Bool) -> Void) {
        // This is a placeholder implementation. Normally you'd send the update to the server.
        completion(true)
    }
}
