
import SwiftUI
import CoreData

struct MatchView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MatchEntity.isAccepted, ascending: false),
                          NSSortDescriptor(keyPath: \MatchEntity.name, ascending: true)],
        animation: .default)
    private var matches: FetchedResults<MatchEntity>

    var body: some View {
        NavigationView {
            List {
                ForEach(matches) { match in
                    NavigationLink(destination: MatchDetail(match: match)) {
                        MatchCard(match: match)
                    }
                }
            }
            .listRowSpacing(20)
            .navigationTitle("Profile Matches")
            .listStyle(InsetGroupedListStyle())
        }
    }
}
