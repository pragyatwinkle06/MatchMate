//
//  Match.swift
//  MatchMate
//

//

struct Match: Codable {
    let id: MatchId
    let name: Name
    let email: String
    let picture: Picture
    var isAccepted: Bool?=nil  // Optional to store acceptance status
 

    struct MatchId: Codable, Equatable {  // Conform to Equatable
        let name: String
        let value: String?
        
        static func ==(lhs: MatchId, rhs: MatchId) -> Bool {
            return lhs.name == rhs.name && lhs.value == rhs.value
        }
    }
    
    struct Picture: Codable {
        let large: String
    }

    struct Name: Codable {
        let title: String
        let first: String
        let last: String
    }
}
