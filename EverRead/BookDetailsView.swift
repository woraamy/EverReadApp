//
//  BookDetailsView.swift
//  EverRead
//
//  Created by Worawalan Chatlatanagulchai on 21/4/2568 BE.
//

import Foundation
// Define in a file like `BookDetailView.swift`
import SwiftUI

// Enum for the tabs within the Book Detail page
enum BookDetailTab {
    case details
    case reviews
}

struct BookDetailView: View {
    let book: Book
    @State private var selectedTab: BookDetailTab = .details
    
    // State for review input
    @State private var reviewText: String = ""
    @State private var reviewRating: Int = 0 // 0 means no rating selected
    
    var body: some View {
        ZStack {
            Color.softWhitePink
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabHeader(title: "Book Details") {
                    print("Signing out...")
                }
                ScrollView {
                    VStack(spacing: 20) {
                        AsyncImage(url: URL(string: book.thumbnailUrl ?? "")) { phase in
                            if let image = phase.image {
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .shadow(radius: 5)
                            } else if phase.error != nil {
                                Image(systemName: "book.closed")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.gray)
                                    .frame(height: 200) // Maintain space
                                    .background(Color.gray.opacity(0.1))
                            } else {
                                ProgressView()
                                    .frame(height: 200) // Maintain space
                            }
                        }
                        .frame(maxHeight: 250) // Limit cover height
                        .padding(.top)
                        
                        // --- Title & Author ---
                        Text(book.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.darkPinkBrown)
                        Text("by \(book.authors)")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        // --- Reading Status & Rating ---
                        Text("Currently Reading") // Placeholder status
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.vertical, 2)
                        
                        StarRatingView(rating: .constant(Int(book.averageRating?.rounded() ?? 0)), // Use book's rating
                                       maxRating: 5, interactive: false) // Non-interactive display
                        
                        
                        // --- Tab Buttons ---
                        HStack(spacing: 0) {
                            DetailTabButton(label: "Details", tab: .details, selectedTab: $selectedTab)
                            DetailTabButton(label: "Reviews", tab: .reviews, selectedTab: $selectedTab)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.white) // White background for the tab bar itself
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.2), radius: 3, y: 2)
                        .padding(.horizontal)
                        
                        
                        // --- Tab Content ---
                        Group {
                            switch selectedTab {
                            case .details:
                                BookDetailsTabView(description: book.description)
                            case .reviews:
                                BookReviewsTabView(book: book, reviewText: $reviewText, reviewRating: $reviewRating)
                            }
                        }
                        .padding(.horizontal)
                        
                    } // End Main VStack
                    .padding(.bottom, 30) // Add padding at the bottom
                    
                } // End ScrollView
                .background(Color.softWhitePink.ignoresSafeArea())
                //        .navigationTitle("Book Details")
                .foregroundColor(.darkPinkBrown) // Default text color for this view
            }
        }
    }}

// --- Reusable Tab Button for Details/Reviews ---
struct DetailTabButton: View {
    let label: String
    let tab: BookDetailTab
    @Binding var selectedTab: BookDetailTab

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                 selectedTab = tab
            }
        } label: {
            Text(label)
                .fontWeight(selectedTab == tab ? .bold : .regular)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(selectedTab == tab ? Color.redPink.opacity(0.2) : Color.clear) // Subtle background for selected
                .foregroundColor(selectedTab == tab ? .redPink : .gray)
        }
        .buttonStyle(.plain) // Remove default button styling
    }
}


// --- View for the Details Tab Content ---
struct BookDetailsTabView: View {
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Details") // Section Header (Optional)
                .font(.title3)
                .fontWeight(.semibold)

            Text(description)
                .lineSpacing(5)

            Spacer() // Pushes button to bottom if space allows

            Button("Update Progress") {
                print("Update Progress tapped")
                // Add action here
            }
            .buttonStyle(PrimaryButtonStyle()) // Use a custom button style

        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.1), radius: 3, y: 1)
    }
}

// --- View for the Reviews Tab Content ---
struct BookReviewsTabView: View {
    let book: Book // Pass the book if needed for context
    @Binding var reviewText: String
    @Binding var reviewRating: Int

    var body: some View {
         VStack(alignment: .leading, spacing: 15) {
             // --- Display Existing Reviews (Placeholder) ---
             Text("Reviews") // Section Header
                 .font(.title3)
                 .fontWeight(.semibold)
                 .padding(.bottom, 5)

             // Replace with actual review data later
             ForEach(0..<2) { i in
                 ReviewCard(name: "User \(i+1)", book: book.title, rating: 4, detail:"Placeholder review text goes here. It was a good read!")
                     .padding(.bottom, 5)
             }
             // Divider() // Optional separator

             // --- Write a Review Section ---
             Text("Write A Review")
                 .font(.headline)
                 .padding(.top)

             StarRatingView(rating: $reviewRating, maxRating: 5, interactive: true)
                 .padding(.bottom, 5)

             TextEditor(text: $reviewText)
                .frame(height: 100)
                .border(Color.gray.opacity(0.3))
                .cornerRadius(5)
                .overlay(
                     // Placeholder text if TextEditor is empty
                     reviewText.isEmpty ? Text("Share your thoughts...")
                         .foregroundColor(.gray.opacity(0.6))
                         .padding(8)
                         .allowsHitTesting(false) : nil // Prevents placeholder from blocking typing
                     , alignment: .topLeading
                 )


             Button("Submit Review") {
                 print("Submit Review tapped. Rating: \(reviewRating), Text: \(reviewText)")
                 // Add action here: Save the review, clear fields etc.
             }
             .buttonStyle(PrimaryButtonStyle())
             .disabled(reviewRating == 0 || reviewText.isEmpty) // Disable if no rating or text

         }
         .padding()
         .background(Color.white)
         .cornerRadius(10)
         .shadow(color: .gray.opacity(0.1), radius: 3, y: 1)
    }
}

// --- Custom Button Style ---
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.redPink)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0) // Add slight press effect
             .opacity(configuration.isPressed ? 0.9 : 1.0)
    }
}


// --- Star Rating Component ---
// (You might already have this, or use this basic version)
struct StarRatingView: View {
    @Binding var rating: Int // Current selected rating
    var maxRating: Int = 5
    var interactive: Bool = true
    var starSize: CGFloat = 25
    var starColor: Color = .goldStar
    var emptyColor: Color = .gray.opacity(0.3)

    var body: some View {
        HStack {
            ForEach(1...maxRating, id: \.self) { number in
                Image(systemName: number <= rating ? "star.fill" : "star")
                    .resizable()
                    .scaledToFit()
                    .frame(width: starSize, height: starSize)
                    .foregroundColor(number <= rating ? starColor : emptyColor)
                    .onTapGesture {
                        if interactive {
                            rating = number
                        }
                    }
            }
        }
    }
}

//// --- Placeholder Review Card (Adapt your existing one) ---
//struct ReviewCard: View {
//     let name: String
//     let book: String // Included for context, might not be needed if always shown on book page
//     let rating: Int
//     let detail: String
//
//    var body: some View {
//         VStack(alignment: .leading) {
//             HStack {
//                 Text(name).fontWeight(.bold)
//                 Spacer()
//                 StarRatingView(rating: .constant(rating), maxRating: 5, interactive: false, starSize: 15)
//             }
//             // Text("Reviewed: \(book)").font(.caption).foregroundColor(.gray) // Optional book title
//             Text(detail)
//                 .font(.body)
//                 .lineLimit(3) // Limit lines displayed initially
//         }
//         .padding(10)
//         .background(Color.softWhitePink.opacity(0.5)) // Slightly different background
//         .cornerRadius(8)
//    }
//}


// Preview for BookDetailView
struct BookDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Wrap in NavigationView for preview context
        NavigationView {
            BookDetailView(book: Book.example)
        }
         .preferredColorScheme(.light)
    }
}
