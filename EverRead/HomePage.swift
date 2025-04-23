//
//  HomePage.swift
//  EverRead
//
//  Created by Worawalan Chatlatanagulchai on 22/4/2568 BE.
//

import Foundation
import SwiftUI

struct HomePage: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.softWhitePink // Assuming Color.softWhitePink is defined elsewhere
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // MARK: - Header
                    HStack {
                        HStack(spacing: 5) {
                            Image("logo") // Use the image from Assets
                                .resizable()
                                .scaledToFit()
                                .frame(height: 60)
                            Text("Ever Read")
                                .font(.system(size: 32))
                                .fontWeight(.semibold)
                        }

                        Spacer()

                        NavigationLink(destination: ProfileView()) { // Assuming ProfileView exists
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                                .foregroundColor(Color.black) // Consider using .primary or a theme color
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)

                    // MARK: - Main Scrollable Content
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) { // Added spacing
                            // MARK: - Reading Goals
                            VStack(alignment: .leading) {
                                HStack(spacing: 15) {
                                    ReadGoalCard()
                                }
                                .padding(.horizontal)
                            }

                            // MARK: - Currently Reading Section
                            BookSection(
                                title: "Currently Reading",
                                books: viewModel.currentlyReading,
                                isLoading: viewModel.isLoadingCurrentlyReading
                            )

                            // MARK: - Want to Read Section
                            BookSection(
                                title: "Want To Read",
                                books: viewModel.wantToRead,
                                isLoading: viewModel.isLoadingWantToRead
                            )

                            // MARK: - Recent Reviews Section
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Recent Reviews")
                                        .font(.title3)
                                        .fontWeight(.bold)

                                    Spacer()

                                    // Assuming you have an AllReviewsView or similar
                                    NavigationLink(destination: Text("All Reviews Placeholder")) {
                                        Text("View All")
                                            .font(.subheadline)
                                            .foregroundColor(.redPink) // Assuming Color.redPink defined
                                    }
                                }
                                .padding(.horizontal)

                                if viewModel.recentReviews.isEmpty && !viewModel.isLoadingReviews {
                                    Text("No recent reviews.")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .padding(.horizontal)
                                } else if viewModel.isLoadingReviews {
                                     ProgressView()
                                        .padding()
                                } else {
                                    ForEach(viewModel.recentReviews) { review in
                                        // *** CHANGE THIS PART ***
                                        // Extract data from the 'review' object and pass it
                                        // to the original ReviewCard initializer.
                                        ReviewCard(
                                            name: review.username,        // Pass username to name
                                            book: review.book.title,      // Pass book title string to book
                                            rating: review.rating,        // Pass rating to rating
                                            detail: review.content        // Pass review content to detail
                                        )
                                        // *** END CHANGE ***
                                            .padding(.horizontal) // Keep the horizontal padding for the card
                                            .padding(.bottom, 8)  // Keep the bottom padding
                                    }
                                }

                            } // End Recent Reviews VStack
                            .padding(.bottom, 20) // Add padding at the end of the ScrollView content

                        } // End Main VStack in ScrollView
                        .padding(.top, 15) // Add padding at the top of the ScrollView content
                    } // End ScrollView
                } // End Main VStack
            } // End ZStack
            .foregroundColor(.darkPinkBrown) // Assuming Color.darkPinkBrown defined
            .onAppear {
                // Trigger fetching mock data when the view appears
                viewModel.fetchBooks()
                viewModel.fetchReviews()
            }
        } // End NavigationStack
    }
}

// Book Section Component
struct BookSection: View {
    let title: String
    let books: [Book]
    let isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)

                Spacer()

                // Only show "View All" if there are books or it's not loading
                if !isLoading && !books.isEmpty {
                    // Assuming you have an AllBooksView or similar
                    NavigationLink(destination: Text("All \(title) Placeholder")) {
                        Text("View All")
                            .font(.subheadline)
                            .foregroundColor(.redPink) // Assuming defined
                    }
                }
            }
            .padding(.horizontal)

            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding()
                .frame(height: 190) // Give loading state a consistent height
            } else if books.isEmpty {
                 Text("No books in this section yet.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .frame(height: 190, alignment: .center) // Consistent height
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(books) { book in
                            // Assuming BookDetailView exists
                            NavigationLink(destination: BookDetailView(book: book)) {
                                BookItem(book: book)
                            }
                            // Make the whole item tappable, not just the text/image
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5) // Add slight vertical padding
                }
            }
        }
    }
}

// Book Item Component
struct BookItem: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Book Cover - **FIXED AsyncImage URL Handling**
            AsyncImage(url: URL(string: book.thumbnailUrl ?? "")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 100, height: 150)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 150)
                        .clipped() // Use clipped instead of fill to prevent overflow
                case .failure:
                    Image(systemName: "book.closed") // Placeholder on failure
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                        .frame(width: 100, height: 150) // Ensure placeholder fills space
                        .background(Color.gray.opacity(0.1))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 100, height: 150)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1) // Subtle border
            )


            // Book Title
            Text(book.title)
                .font(.system(size: 14, weight: .medium))
                .lineLimit(1)
                .frame(width: 100, alignment: .leading)

            // Author Name - **FIXED Author Display**
            Text(book.authors) // Directly use the computed property
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineLimit(1)
                .frame(width: 100, alignment: .leading)
        }
        .frame(width: 100) // Keep overall frame
    }
}

// Review Item Component
struct ReviewItem: View {
    let review: Review

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Book thumbnail - **FIXED AsyncImage URL Handling**
            AsyncImage(url: URL(string: review.book.thumbnailUrl ?? "")) { phase in
                 switch phase {
                 case .empty:
                     ProgressView()
                         .frame(width: 60, height: 80)
                 case .success(let image):
                     image
                         .resizable()
                         .aspectRatio(contentMode: .fill)
                         .frame(width: 60, height: 80)
                         .clipped()
                 case .failure:
                     Image(systemName: "book.closed") // Placeholder on failure
                         .resizable()
                         .scaledToFit()
                         .frame(width: 30, height: 30)
                         .foregroundColor(.gray)
                         .frame(width: 60, height: 80) // Ensure placeholder fills space
                         .background(Color.gray.opacity(0.1))
                 @unknown default:
                     EmptyView()
                 }
            }
            .frame(width: 60, height: 80)
            .cornerRadius(5)
             .overlay(
                 RoundedRectangle(cornerRadius: 5)
                     .stroke(Color.gray.opacity(0.2), lineWidth: 1) // Subtle border
             )

            VStack(alignment: .leading, spacing: 5) {
                Text(review.username)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("Reviewed \(review.book.title)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1) // Ensure title doesn't wrap oddly

                // Rating stars
                HStack(spacing: 3) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= review.rating ? "star.fill" : "star")
                            .foregroundColor(star <= review.rating ? .yellow : .gray.opacity(0.5)) // Make empty stars fainter
                            .font(.system(size: 12))
                    }
                }

                Text(review.content)
                    .font(.caption)
                    .lineLimit(2) // Limit review content preview
            }

            Spacer()
        }
        .padding()
        .background(Color.white) 
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}


// MARK: - View Model

class HomeViewModel: ObservableObject {
    @Published var currentlyReading: [Book] = []
    @Published var wantToRead: [Book] = []
    @Published var recentReviews: [Review] = []

    @Published var isLoadingCurrentlyReading = false
    @Published var isLoadingWantToRead = false
    @Published var isLoadingReviews = false

    // Reading goals tracking
    @Published var yearlyBookCount = 7
    @Published var yearlyBookGoal = 24
    @Published var monthlyBookCount = 1
    @Published var monthlyBookGoal = 2

    // Ensure division by zero doesn't happen if goal is 0
    var yearlyProgress: Double {
        guard yearlyBookGoal > 0 else { return 0 }
        return min(1.0, max(0.0, Double(yearlyBookCount) / Double(yearlyBookGoal))) // Clamp between 0 and 1
    }

    var monthlyProgress: Double {
        guard monthlyBookGoal > 0 else { return 0 }
        return min(1.0, max(0.0, Double(monthlyBookCount) / Double(monthlyBookGoal))) // Clamp between 0 and 1
    }

    // --- MOCK DATA FETCHING ---
    // Uses the correct Book initializer now

    func fetchBooks() {
        // Fetch Currently Reading books
        isLoadingCurrentlyReading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // **FIXED:** Create VolumeInfo first, then Book
            let royalAssassinInfo = VolumeInfo(id: "1_vol", title: "Royal Assassin", authors: ["Robin Hobb"], description: "From the Farseer Trilogy", imageLinks: ImageLinks(smallThumbnail: "https://placeholder.com/book1_small", thumbnail: "https://placeholder.com/book1"), averageRating: 4.5, ratingsCount: 1000, pageCount: 675, publishedDate: "1996", publisher: "Voyager")
            let dawnshardInfo = VolumeInfo(id: "2_vol", title: "Dawnshard", authors: ["Brandon Sanderson"], description: "From the Stormlight Archive", imageLinks: ImageLinks(smallThumbnail: "https://placeholder.com/book2_small", thumbnail: "https://placeholder.com/book2"), averageRating: 4.7, ratingsCount: 800, pageCount: 171, publishedDate: "2020", publisher: "Dragonsteel Entertainment")

            self.currentlyReading = [
                Book(id: "1", volumeInfo: royalAssassinInfo),
                Book(id: "2", volumeInfo: dawnshardInfo)
            ]
            self.isLoadingCurrentlyReading = false
        }

        // Fetch Want to Read books
        isLoadingWantToRead = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
             // **FIXED:** Create VolumeInfo first, then Book
            let babelInfo = VolumeInfo(id: "3_vol", title: "Babel", authors: ["R. F. Kuang"], description: "A fantasy novel about translation", imageLinks: ImageLinks(smallThumbnail: "https://placeholder.com/book3_small", thumbnail: "https://placeholder.com/book3"), averageRating: 4.2, ratingsCount: 1500, pageCount: 545, publishedDate: "2022", publisher: "Harper Voyager")
            let hobbitInfo = VolumeInfo(id: "4_vol", title: "The Hobbit", authors: ["J.R.R. Tolkien"], description: "A classic fantasy adventure", imageLinks: ImageLinks(smallThumbnail: "https://placeholder.com/book4_small", thumbnail: "https://placeholder.com/book4"), averageRating: 4.8, ratingsCount: 5000, pageCount: 310, publishedDate: "1937", publisher: "George Allen & Unwin")
            let circeInfo = VolumeInfo(id: "5_vol", title: "Circe", authors: ["Madeline Miller"], description: "A retelling of the story of Circe", imageLinks: ImageLinks(smallThumbnail: "https://placeholder.com/book5_small", thumbnail: "https://placeholder.com/book5"), averageRating: 4.3, ratingsCount: 2500, pageCount: 393, publishedDate: "2018", publisher: "Little, Brown and Company")

            self.wantToRead = [
                Book(id: "3", volumeInfo: babelInfo),
                Book(id: "4", volumeInfo: hobbitInfo),
                Book(id: "5", volumeInfo: circeInfo)
            ]
            self.isLoadingWantToRead = false
        }
    }

    func fetchReviews() {
        isLoadingReviews = true // Start loading indicator
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
             // **FIXED:** Create VolumeInfo and Book correctly for the reviews
             let babelInfo = VolumeInfo(id: "3_vol", title: "Babel", authors: ["R. F. Kuang"], description: "A fantasy novel about translation", imageLinks: ImageLinks(smallThumbnail: "https://placeholder.com/book3_small", thumbnail: "https://placeholder.com/book3"), averageRating: 4.2, ratingsCount: 1500, pageCount: 545, publishedDate: "2022", publisher: "Harper Voyager")
             let babelBook = Book(id: "3", volumeInfo: babelInfo)

            self.recentReviews = [
                Review(
                    id: "rev1",
                    username: "BookLover123",
                    book: babelBook, // Use the correctly created book
                    rating: 5,
                    content: "Absolutely phenomenal! Kuang weaves language and history into a gripping, heartbreaking story. A must-read."
                ),
                Review(
                    id: "rev2",
                    username: "ReaderX",
                    book: babelBook,
                    rating: 4,
                    content: "Very dense and academic at times, but ultimately rewarding. The world-building is incredible."
                )
                
            ]
            self.isLoadingReviews = false
        }
    }

    // Api fetching
    func fetchBooksFromApi(query: String, completion: @escaping ([Book]) -> Void) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=\(encodedQuery)") else {
            print("Invalid URL or Query")
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                DispatchQueue.main.async { completion([]) }
                return
            }

            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async { completion([]) }
                return
            }

            // print(String(data: data, encoding: .utf8) ?? "Could not print data")

            do {
                let result = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)
                // **FIXED:** No extra mapping needed here if GoogleBooksResponse defines items as [Book]?
                let books = result.items ?? [] // Use nil-coalescing for safety

                DispatchQueue.main.async {
                    completion(books)
                }
            } catch {
                // Print detailed decoding errors
                print("Decoding error: \(error)")
                if let decodingError = error as? DecodingError {
                    print("Decoding Error Details: \(decodingError)")
                }
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }.resume()
    }
}

// MARK: - Preview
// Add other placeholder views if needed

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
            // Optional: Add mock data directly to preview if needed for specific states
            .environmentObject(HomeViewModel()) // Inject ViewModel if subviews need it directly
    }
}
