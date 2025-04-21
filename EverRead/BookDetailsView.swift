//
//  BookDetailsView.swift
//  EverRead
//
//  Created by Worawalan Chatlatanagulchai on 21/4/2568 BE.
//

import Foundation
// Define in a file like `BookDetailView.swift`
import SwiftUI

//// Enum for the tabs within the Book Detail page
enum DetailTab {
    case Detail
    case GoogleReview
}

struct BookDetailView: View {
    let book: Book
    @State private var selectedTab: DetailTab = .Detail
    
    // State for review input
    @State private var reviewText: String = ""
    @State private var reviewRating: Int = 0 // 0 means no rating selected
    
    var body: some View {
        ZStack {
            Color.softWhitePink
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
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
                            .foregroundColor(.black)
                            .padding(.vertical, 2)
                            .background(Color.redPink)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        StarRatingView(rating: .constant(Int(book.averageRating?.rounded() ?? 0)), // Use book's rating
                                       maxRating: 5, interactive: false) // Non-interactive display
                        
                        
                        // --- Tab Buttons ---
                        HStack(spacing: 0) {
                            DetailTabButton(label: "Details", detail_tab: .Detail, selectedTab: $selectedTab)
                            DetailTabButton(label: "Review", detail_tab: .GoogleReview, selectedTab: $selectedTab)
                        }.frame(width:350, height:40 )
                            .background(Color.redPink)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.bottom, 10)
                        
                        
                        
                        // --- Tab Content ---
                        Group {
                            switch selectedTab {
                            case .Detail:
                                BookDetailsTabView(description: book.description,
                                    pageCount: book.pageCount,
                                    publisher: book.publisher,
                                    publishedDate: book.publishedDate // <-- Pass publishedDate
                                               )
                            case .GoogleReview:
                                BookReviewsTabView(book: book, reviewText: $reviewText, reviewRating: $reviewRating)
                            
                            }
                        }
                        .padding(.horizontal)
                        
                    }
                    .padding(.bottom, 30)
                }
                .background(Color.softWhitePink.ignoresSafeArea())
                .foregroundColor(.darkPinkBrown)
            }
        }
    }}


struct BookDetailsTabView: View {
    let description: String
    let pageCount: Int?
    let publisher: String?
    let publishedDate: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Book Description")
                .font(.title3)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 5) {
                // Page Count
                if let count = pageCount, count > 0 {
                    HStack(spacing: 5) {
                        Image(systemName: "book.pages")
                            .foregroundColor(.gray)
                            .frame(width: 20, alignment: .center)
                        Text("\(count) pages")
                    }
                }

                if let dateStr = publishedDate, !dateStr.isEmpty {
                    HStack(spacing: 5) {
                        Image(systemName: "calendar")
                             .foregroundColor(.gray)
                             .frame(width: 20, alignment: .center)
                        Text("Published: \(dateStr)")
                    }
                }

                // Publisher
                if let pub = publisher, !pub.isEmpty {
                    HStack(spacing: 5) {
                        Image(systemName: "building.columns")
                            .foregroundColor(.gray)
                            .frame(width: 20, alignment: .center)
                        Text("Publisher: \(pub)")
                    }
                }
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            .padding(.bottom, 10)


            Text(description)
                .lineSpacing(5)

            Spacer()

            Button("Update Progress") {
                print("Update Progress tapped")
            }
            .buttonStyle(PrimaryButtonStyle())

        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.1), radius: 3, y: 1)
    }
}

struct BookReviewsTabView: View {
    let book: Book
    @Binding var reviewText: String
    @Binding var reviewRating: Int

    var body: some View {
         VStack(alignment: .leading, spacing: 15) {
             Text("Reviews")
                 .font(.title3)
                 .fontWeight(.semibold)
                 .padding(.bottom, 5)

             ForEach(0..<2) { i in
                 ReviewCard(name: "User \(i+1)", book: book.title, rating: 4, detail:"Placeholder review text goes here. It was a good read!")
                     .padding(.bottom, 5)
             }
            Divider()
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
                     reviewText.isEmpty ? Text("Share your thoughts...")
                         .foregroundColor(.gray.opacity(0.6))
                         .padding(8)
                         .allowsHitTesting(false) : nil
                     , alignment: .topLeading
                 )


             Button("Submit Review") {
                 print("Submit Review tapped. Rating: \(reviewRating), Text: \(reviewText)")
             }
             .buttonStyle(PrimaryButtonStyle())
             .disabled(reviewRating == 0 || reviewText.isEmpty)
         }
         .padding()
         .background(Color.white)
         .cornerRadius(10)
         .shadow(color: .gray.opacity(0.1), radius: 3, y: 1)
    }
}

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


struct StarRatingView: View {
    @Binding var rating: Int
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


struct BookDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Wrap in NavigationView for preview context
        NavigationView {
            BookDetailView(book: Book.example)
        }
         .preferredColorScheme(.light)
    }
}
