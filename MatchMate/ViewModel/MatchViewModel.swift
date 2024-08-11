import Foundation
import CoreData
import Combine

class MatchViewModel: ObservableObject {
    @Published var matches: [MatchEntity] = []
    private var context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()

    init(context: NSManagedObjectContext) {
        self.context = context
        loadCachedMatches() // Load cached matches when the view model is initialized (Offline)
    }

    func fetchAndSaveMatchesFromAPIIfNeeded() {
        if NetworkMonitor.shared.isConnected && PersistenceController.shared.countStoredMatches() == 0 {
            fetchMatchesFromAPI()
        } else {
            print("Offline or data already exists: No API call needed.")
        }
    }

    private func fetchMatchesFromAPI() {
        ApiService.shared.fetchMatches { [weak self] result in
            switch result {
            case .success(let fetchedMatches):
                self?.saveMatches(fetchedMatches)
                self?.loadCachedMatches()
            case .failure(let error):
                print("Failed to fetch matches from API: \(error.localizedDescription)")
            }
        }
    }

    private func saveMatches(_ fetchedMatches: [Match]) {
        let existingIds = matches.map { Match.MatchId(name: $0.idName ?? "", value: $0.idValue) }

        fetchedMatches.forEach { match in
            if !existingIds.contains(match.id) {
                let entity = MatchEntity(context: context)
                entity.idName = match.id.name
                entity.idValue = match.id.value ?? ""
                entity.name = "\(match.name.title) \(match.name.first) \(match.name.last)"
                entity.email = match.email
             
                entity.isAccepted = match.isAccepted ?? false

                if let imageUrl = URL(string: match.picture.large) {
                    ImageCache.shared.downloadImage(from: imageUrl) { [weak entity] imagePath in
                        entity?.pictureURL = imagePath
                        self.saveContext()
                    }
                }
            }
        }
        saveContext()
    }


    private func loadCachedMatches() {
        let fetchRequest: NSFetchRequest<MatchEntity> = MatchEntity.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \MatchEntity.isAccepted, ascending: false),
            NSSortDescriptor(keyPath: \MatchEntity.name, ascending: true)
        ]
        do {
            matches = try context.fetch(fetchRequest)
            print("Number of matches stored in Core Data: \(matches.count)")
        } catch {
            print("Failed to load cached matches: \(error.localizedDescription)")
        }
    }

    func updateMatchStatus(_ match: MatchEntity, isAccepted: Bool) {
        match.isAccepted = isAccepted
        saveContext()

        if NetworkMonitor.shared.isConnected {
            syncStatusWithServer(match)
        }
    }

    private func syncStatusWithServer(_ match: MatchEntity) {
        // Placeholder for actual API call
        print("Syncing status with server for match: \(match.name ?? "Unknown")")
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
}
