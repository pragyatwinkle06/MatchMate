

import CoreData
import Foundation


enum CoreDataError: Error {
    case saveError(String)
    case fetchError(String)
    case updateError(String)
}

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MatchMate")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }

        }
    }

    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }

    // Method to count stored matches in Core Data
    func countStoredMatches() -> Int {
        let fetchRequest: NSFetchRequest<MatchEntity> = MatchEntity.fetchRequest()
        do {
            return try viewContext.count(for: fetchRequest)
        } catch {
            print("Failed to count matches: \(error.localizedDescription)")
            return 0
        }
    }

    // Method to fetch matches from API and save them to Core Data
    func fetchAndSaveMatches() {
        ApiService.shared.fetchMatches { result in
            switch result {
            case .success(let matches):
                for match in matches {
                    do {
                        try self.saveMatch(match)
                    } catch {
                        print("Error saving match: \(error)")
                    }
                }
            case .failure(let error):
                print("Failed to fetch matches from API: \(error)")
            }
        }
    }

    // Method to save a match to Core Data
    func saveMatch(_ match: Match) throws {
        let context = viewContext
        let entity = MatchEntity(context: context)
        // Store id information
               entity.idName = match.id.name
               entity.idValue = match.id.value ?? "" 
        entity.name = "\(match.name.title) \(match.name.first) \(match.name.last)"
        entity.email = match.email
        entity.pictureURL = match.picture.large
        
        entity.isAccepted = match.isAccepted ?? false

        do {
            try context.save()
            print("Saved entity:", entity.name)
        } catch {
            throw CoreDataError.saveError("Failed to save match: \(error)")
        }
    }

    // Method to fetch and save matches only if needed (i.e., if there are no matches stored)
    func fetchAndSaveMatchesIfNeeded() {
        fetchAndSaveMatches()
        
    }

    func fetchMatches() -> [MatchEntity] {
        let fetchRequest: NSFetchRequest<MatchEntity> = MatchEntity.fetchRequest()
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch matches: \(error.localizedDescription)")
            return []
        }
    }

    func updateMatch(_ match: MatchEntity, with status: Bool) {
        match.isAccepted = status
        do {
            try viewContext.save()
            print("Updated match:", match.name ?? "Unknown")
        } catch {
            print("Failed to update match: \(error.localizedDescription)")
        }
    }
}
