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
    @StateObject private var dataManager = DataManager() // Assuming this fetches user profile data
    @EnvironmentObject var session: UserSession // Injected UserSession

    var body: some View {
        let user = dataManager.user // For reading goals

        NavigationStack {
            ZStack {
                Color.softWhitePink // Define this color in your assets or extensions
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // MARK: - Header
                    HStack {
                        HStack(spacing: 5) {
                            Image("logo") // Ensure "logo" is in your assets
                                .resizable()
                                .scaledToFit()
                                .frame(height: 60)
                            Text("Ever Read")
                                .font(.system(size: 32))
                                .fontWeight(.semibold)
                        }
                        Spacer()
                        NavigationLink(destination: ProfileView()) { // Ensure ProfileView is defined
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                                .foregroundColor(Color.black) // Or your app's theme color
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.5).blur(radius: 10)) // Optional: subtle header background

                    // MARK: - Main Scrollable Content
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // MARK: - Reading Goals
                            VStack(alignment: .leading) {
                                HStack(spacing: 15) {
                                    ReadGoalCard( // Ensure ReadGoalCard is defined
                                        yearGoalValue: user?.yearly_book_read ?? 0,
                                        monthGoalValue: user?.monthly_book_read ?? 0,
                                        yearGoalTotal: user?.yearly_goal ?? 0,
                                        monthGoalTotal: user?.month_goal ?? 0
                                    )
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
                                    NavigationLink(destination: Text("All Reviews Placeholder")) {
                                        Text("View All")
                                            .font(.subheadline)
                                            .foregroundColor(.redPink) // Define Color.redPink
                                    }
                                }
                                .padding(.horizontal)

                                if viewModel.isLoadingReviews {
                                    ProgressView().padding()
                                } else if viewModel.recentReviews.isEmpty {
                                    Text("No recent reviews.")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .padding(.horizontal)
                                } else {
                                    ForEach(viewModel.recentReviews) { review in
                                        // Ensure ReviewCard is defined and takes these parameters
                                        ReviewCard(
                                            name: review.username,
                                            book: review.book.title, // Access title via Book struct
                                            rating: review.rating,
                                            detail: review.content
                                        )
                                        .padding(.horizontal)
                                        .padding(.bottom, 8)
                                    }
                                }
                            }
                            .padding(.bottom, 20)
                        }
                        .padding(.top, 15)
                    } // End ScrollView
                } // End Main VStack
            } // End ZStack
            .foregroundColor(.darkPinkBrown) // Define Color.darkPinkBrown
            .onAppear {
                // Trigger fetching data when the view appears, passing the token
                viewModel.fetchHomePageData(token: session.token)
                dataManager.fetchUser()     // Fetches user profile data for goals
            }
        } // End NavigationStack
    }
}


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
                .frame(height: 190)
            } else if books.isEmpty {
                 Text("No books in this section yet.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .frame(height: 190, alignment: .center)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(books) { book in
                            NavigationLink(destination: BookDetailView(book: book)) {
                                BookItem(book: book)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
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
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1) 
            )


            Text(book.title)
                .font(.system(size: 14, weight: .medium))
                .lineLimit(1)
                .frame(width: 100, alignment: .leading)

            Text(book.authors)
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
                    .lineLimit(10)
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
    @Published var recentReviews: [Review] = [] // Assuming Review fetching is separate

    @Published var isLoadingCurrentlyReading = false
    @Published var isLoadingWantToRead = false
    @Published var isLoadingReviews = false // For reviews

    // Reading goals - keeping existing logic
    @Published var yearlyBookCount = 7
    @Published var yearlyBookGoal = 24
    @Published var monthlyBookCount = 1
    @Published var monthlyBookGoal = 2
    
    // Removed @EnvironmentObject var session: UserSession from ViewModel

    var yearlyProgress: Double {
        guard yearlyBookGoal > 0 else { return 0 }
        return min(1.0, max(0.0, Double(yearlyBookCount) / Double(yearlyBookGoal)))
    }

    var monthlyProgress: Double {
        guard monthlyBookGoal > 0 else { return 0 }
        return min(1.0, max(0.0, Double(monthlyBookCount) / Double(monthlyBookGoal)))
    }

    private let apiService = BookAPIService.shared
    // Removed the internal userToken computed property

    // Main function to fetch all necessary data for the home page
    @MainActor // Ensure UI updates are on the main thread
    func fetchHomePageData(token: String?) { // Accept token as a parameter
        fetchCurrentlyReading(token: token)
        fetchWantToRead(token: token)
        fetchReviews(token: token) // Assuming this also might need a token eventually
    }

    @MainActor
    func fetchCurrentlyReading(token: String?) { // Accept token
        isLoadingCurrentlyReading = true
        Task {
            defer { isLoadingCurrentlyReading = false } // Ensure loading state is reset
            do {
                // Use the passed-in token
                guard let validToken = token, !validToken.isEmpty else {
                    print("User token not available for fetching currently reading books.")
                    self.currentlyReading = [] // Clear existing data or show error state
                    return
                }
                self.currentlyReading = try await apiService.fetchCurrentlyReadingBooks(userToken: validToken)
                print("Fetched \(self.currentlyReading.count) currently reading books.")
            } catch {
                self.currentlyReading = [] // Clear on error or keep stale data, up to you
                print("Error fetching currently reading books: \(error.localizedDescription)")
                // Optionally, publish an error message to the UI
            }
        }
    }

    @MainActor
    func fetchWantToRead(token: String?) { // Accept token
        isLoadingWantToRead = true
        Task {
            defer { isLoadingWantToRead = false }
            do {
                guard let validToken = token, !validToken.isEmpty else {
                    print("User token not available for fetching want to read books.")
                    self.wantToRead = []
                    return
                }
                self.wantToRead = try await apiService.fetchWantToReadBooks(userToken: validToken)
                print("Fetched \(self.wantToRead.count) want to read books.")
            } catch {
                self.wantToRead = []
                print("Error fetching want to read books: \(error.localizedDescription)")
            }
        }
    }

    // Mock review fetching (adapt if it needs a token)
    @MainActor
    func fetchReviews(token: String?) { // Accept token, even if not used by mock
        isLoadingReviews = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Simulate network delay
            // If reviews API call needs a token, use it here.
            // For now, using your existing mock reviews logic
            let babelInfo = VolumeInfo(id: "3_vol", title: "Babel", authors: ["R. F. Kuang"], description: "A fantasy novel about translation", imageLinks: ImageLinks(smallThumbnail: "https://placeholder.com/book3_small", thumbnail: "https://placeholder.com/book3"), averageRating: 4.2, ratingsCount: 1500, pageCount: 545, publishedDate: "2022", publisher: "Harper Voyager")
            let babelBook = Book(id: "3_vol", volumeInfo: babelInfo)

            self.recentReviews = [
                Review(id: "rev1", username: "BookLover123", book: babelBook, rating: 5, content: "Absolutely phenomenal! Kuang weaves language and history into a gripping, heartbreaking story. A must-read."),
                Review(id: "rev2", username: "ReaderX", book: babelBook, rating: 4, content: "Very dense and academic at times, but ultimately rewarding. The world-building is incredible.")
            ]
            self.isLoadingReviews = false
        }
    }


    // This function is for searching Google Books API, keep it as is if used for search functionality.
    // This typically does not require user authentication token.
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

            do {
                let result = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)
                let books = result.items ?? []
                DispatchQueue.main.async {
                    completion(books)
                }
            } catch {
                print("Decoding error from Google Books API: \(error)")
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


struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
            .environmentObject(HomeViewModel())
            .environmentObject(UserSession())
    }
}
