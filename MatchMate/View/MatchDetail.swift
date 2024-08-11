//
//  MatchDetail.swift
//  MatchMate
//

//

import SwiftUI
import CoreData

struct MatchDetail: View {
    @ObservedObject var match: MatchEntity
    @Environment(\.managedObjectContext) private var viewContext
    @State private var localIsAccepted: Bool?

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: match.pictureURL ?? ""))
                .frame(width: 150, height: 150) // Increased image size
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 3)

            Text(match.fullName)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(match.email ?? "No Email")
                .foregroundColor(.secondary)
                .font(.title2)
            
       

            Spacer()

            HStack {
                Capsule()
                    .fill(localIsAccepted == true ? Color.green : Color.clear)
                    .frame(width: 120, height: 35) // Increased capsule size
                    .overlay(
                        Text("Accept")
                            .foregroundColor(localIsAccepted == true ? .white : .green)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    )
                    .onTapGesture {
                        localIsAccepted = true
                        match.isAccepted = true
                        saveContext()
                    }

                Capsule()
                    .fill(localIsAccepted == false ? Color.red : Color.clear)
                    .frame(width: 120, height: 35) // Increased capsule size
                    .overlay(
                        Text("Decline")
                            .foregroundColor(localIsAccepted == false ? .white : .red)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    )
                    .onTapGesture {
                        localIsAccepted = false
                        match.isAccepted = false
                        saveContext()
                    }
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 20)
        .onAppear {
            localIsAccepted = match.isAccepted
        }
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
