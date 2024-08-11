//
//  MatchCard.swift
//  MatchMate
//

//

import SwiftUI
import CoreData

struct MatchCard: View {
    @ObservedObject var match: MatchEntity
    @Environment(\.managedObjectContext) private var viewContext
    @State private var localIsAccepted: Bool?
    @State private var uiImage: UIImage?

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            // Profile Image
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .cornerRadius(15)
                    .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white, lineWidth: 3))
                    .shadow(radius: 5)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .cornerRadius(15)
                    .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white, lineWidth: 3))
                    .shadow(radius: 5)
            }

            // Name and Email
            VStack(spacing: 5) {
                Text(match.fullName ?? "Unknown Name")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text(match.email ?? "No Email")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer().frame(height: 10)

            // Action Buttons or Status
            if let localIsAccepted = localIsAccepted {
                Text(localIsAccepted ? "Accepted" : "Declined")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(localIsAccepted ? Color.green : Color.red)
                    .cornerRadius(8)
            } else {
                HStack(spacing: 20) {
                    // Accept Button
                    Capsule()
                        .fill(Color.green.opacity(0.1))
                        .frame(width: 100, height: 40)
                        .overlay(
                            Text("Accept")
                                .foregroundColor(.green)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        )
                        .onTapGesture {
                            localIsAccepted = true
                            match.isAccepted = true
                            saveContext()
                        }

                    // Decline Button
                    Capsule()
                        .fill(Color.red.opacity(0.1))
                        .frame(width: 100, height: 40)
                        .overlay(
                            Text("Decline")
                                .foregroundColor(.red)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        )
                        .onTapGesture {
                            localIsAccepted = false
                            match.isAccepted = false
                            saveContext()
                        }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.05)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing))
        )
        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
        .onAppear {
            localIsAccepted = match.isAccepted
            loadImage()
        }
    }

    private func loadImage() {
        guard let pictureURL = match.pictureURL else { return }

        if let image = ImageCache.shared.getImage(forKey: pictureURL) {
            self.uiImage = image
        } else {
            ImageCache.shared.downloadImage(from: URL(string: pictureURL)!) { _ in
                self.uiImage = ImageCache.shared.getImage(forKey: pictureURL)
            }
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
