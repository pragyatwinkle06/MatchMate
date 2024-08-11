//
//  MatchEntity+CoreDataProperties.swift
//  MatchMate

//
//

import Foundation
import CoreData


extension MatchEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MatchEntity> {
        return NSFetchRequest<MatchEntity>(entityName: "MatchEntity")
    }

    @NSManaged public var email: String?
    @NSManaged public var idName: String?
    @NSManaged public var isAccepted:Bool
    @NSManaged public var name: String?
    @NSManaged public var pictureURL: String?
    @NSManaged public var idValue: String?


}

extension MatchEntity : Identifiable {

}
