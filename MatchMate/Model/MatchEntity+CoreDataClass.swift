//
//  MatchEntity+CoreDataClass.swift
//  MatchMate

//
//

import Foundation
import CoreData

@objc(MatchEntity)
public class MatchEntity: NSManagedObject {

}

extension MatchEntity {
    var fullName: String {
        return name ?? ""
    }
}
