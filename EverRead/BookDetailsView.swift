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
    case Review
}

struct BookDetailView: View {
    let book: Book // Your Google Book model
    
    @State private var selectedTab: DetailTab = .Detail
    @State private var reviewText: String = ""
    @State private var reviewRating: Int = 0
    @State private var showingUpdateProgressSheet = false
    
    // User's progress for this specific book
    @State private var currentUserBookStatus: BookReadingStatus = .wantToRead
    @State private var currentUserBookPage: Int? = nil
    @State private var isLoadingUserProgress: Bool = true
    @State private var fetchErrorMessage: String? = nil
    
    @EnvironmentObject var session: UserSession // Ensure UserSession is correctly defined and provides 'token'

    // Helper to make image URLs secure
    private func secureImageUrl(_ urlString: String?) -> URL? {
        guard let urlString = urlString, !urlString.isEmpty else { return nil }
        var secureUrlString = urlString
        if urlString.lowercased().hasPrefix("http://") {
            secureUrlString = "https://" + urlString.dropFirst("http://".count)
        }
        return URL(string: secureUrlString)
    }

    // Main body of the view
    var body: some View {
        // Check if user is logged in
        if !session.isLoggedIn { // Assuming UserSession has an isLoggedIn property
            SignInView() // Ensure SignInView is defined
        } else {
            content // Extracted main content to a computed property
        }
    }

    // Extracted main content view
    private var content: some View {
        ZStack {
            Color.softWhitePink.ignoresSafeArea() // Ensure Color.softWhitePink is defined
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 15) { // Main content VStack
                        bookHeaderSection // Extracted book image, title, author
                        userProgressSection // Extracted user progress display
                        starRatingAndUpdateButton // Extracted star rating and update button
                        tabSelectionSection // Extracted tab buttons
                        tabContentSection // Extracted tab content (Details or Reviews)
                    }
                    .padding(.bottom) // Add some padding at the bottom of the scroll content
                }
            }
        }
        .sheet(isPresented: $showingUpdateProgressSheet) {
            // Sheet content is now directly defined here
            BookStatusUpdateView(
                book: book,
                currentStatus: currentUserBookStatus,
                currentPage: currentUserBookPage,
                onUpdateComplete: {
                    fetchUserBookProgress() // Refresh progress after update
                }
            )
            .environmentObject(session) // Pass UserSession to the sheet
        }
        .onAppear {
            fetchUserBookProgress() // Fetch initial progress when the view appears
        }
        .navigationTitle(book.title)
    }

    // MARK: - Extracted View Components

    // Displays the book cover image
    private var bookCoverImage: some View {
        Group { // Use Group to handle conditional logic cleanly
            if let secureUrl = secureImageUrl(book.thumbnailUrl) {
                AsyncImage(url: secureUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fit).shadow(radius: 5)
                    case .failure:
                        Image(systemName: "book.closed").resizable().aspectRatio(contentMode: .fit).foregroundColor(.gray).frame(height: 200).background(Color.gray.opacity(0.1))
                    case .empty:
                        ProgressView().frame(height: 200)
                    @unknown default:
                        EmptyView().frame(height: 200)
                    }
                }
            } else {
                Image(systemName: "book.closed").resizable().aspectRatio(contentMode: .fit).foregroundColor(.gray).frame(height: 200).background(Color.gray.opacity(0.1))
            }
        }
        .frame(maxHeight: 250)
        .padding(.top)
    }

    // Displays book title and authors
    private var bookTitleAndAuthor: some View {
        VStack {
            Text(book.title)
                .font(.title2).fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(.darkPinkBrown) // Ensure Color.darkPinkBrown is defined
            Text("by \(book.authors)") // Using the safe computed property
                .font(.headline)
                .foregroundColor(.gray)
        }
    }
    
    // Section for book image, title, and author
    private var bookHeaderSection: some View {
        VStack(spacing: 10) { // Add spacing if needed
            bookCoverImage
            bookTitleAndAuthor
        }
    }

    // Displays the current user's progress for this book
    private var userProgressSection: some View {
        VStack {
            if isLoadingUserProgress {
                ProgressView()
            } else if let errorMsg = fetchErrorMessage {
                Text(errorMsg)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else {
                Text("Status: \(currentUserBookStatus.displayName)")
                if currentUserBookStatus == .currentlyReading, let page = currentUserBookPage {
                    if let total = book.pageCount, total > 0 {
                        Text("Page: \(page) of \(total)")
                    } else {
                        Text("Page: \(page)")
                    }
                }
            }
        }
        .font(.caption).foregroundColor(.black)
        .padding(.vertical, 8).padding(.horizontal, 15)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.redPink.opacity(0.8))) // Ensure Color.redPink
        .onTapGesture {
            if fetchErrorMessage != nil { // Allow retry if there was an error
                fetchUserBookProgress()
            }
        }
    }

    // Displays the book's average star rating and the "Update Progress" button
    private var starRatingAndUpdateButton: some View {
        VStack(spacing: 15) {
            StarRatingView(rating: .constant(Int(book.averageRating?.rounded() ?? 0)), maxRating: 5, interactive: false) // Ensure StarRatingView is defined
                .padding(.bottom, 5)
            
            Button("Update My Reading Progress") {
                self.showingUpdateProgressSheet = true
            }
            .buttonStyle(PrimaryButtonStyle()) // Ensure PrimaryButtonStyle is defined
            .padding(.horizontal)
        }
    }

    // Displays the tab selection buttons (Details, Google Review)
    private var tabSelectionSection: some View {
        HStack(spacing: 0) {
            DetailTabButton(label: "Details", detail_tab: .Detail, selectedTab: $selectedTab) // Ensure DetailTabButton is defined
            DetailTabButton(label: "Review", detail_tab: .Review, selectedTab: $selectedTab)
        }
        .frame(width: 350, height: 40) // Consider using geometry reader or adaptive width
        .background(Color.redPink)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.vertical, 10)
    }

    // Displays the content based on the selected tab
    @ViewBuilder // Use @ViewBuilder for properties returning different view types in a switch
    private var tabContentSection: some View {
        Group { // Group is fine here, or can be removed if @ViewBuilder is on the computed var
            switch selectedTab {
            case .Detail:
                // Corrected: BookDetailsTabView should take the whole 'book' object
                BookDetailsTabView(description: book.description, pageCount: book.pageCount, publisher: book.publisher, publishedDate: book.publishedDate) // Ensure BookDetailsTabView is defined to take `book: Book`
            case .Review:
                BookReviewsTabView(book: book, reviewText: $reviewText, reviewRating: $reviewRating) // Ensure BookReviewsTabView is defined
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Data Fetching

    // Function to fetch user's current progress for THIS book from your backend
    func fetchUserBookProgress() {
        isLoadingUserProgress = true
        fetchErrorMessage = nil // Clear previous error
        // print("Fetching user progress for book ID: \(book.id)...")
        Task {
            do {
                guard let token = session.token else {
                    await MainActor.run {
                        self.isLoadingUserProgress = false
                        self.fetchErrorMessage = "Not logged in. Please log in to see your progress."
                    }
                    return
                }
                // Assuming BookAPIService.shared.fetchUserBookProgress is correctly implemented
                let userBookData = try await BookAPIService.shared.fetchUserBookProgress(apiId: book.id, userToken: token)
                
                await MainActor.run {
                    self.currentUserBookStatus = userBookData.status
                    self.currentUserBookPage = userBookData.current_page
                    self.isLoadingUserProgress = false
                    // print("Successfully fetched user progress: Status - \(userBookData.status.displayName), Page - \(userBookData.current_page ?? -1)")
                }
            }catch let error { // Catching the error more generically first
                await MainActor.run {
                    self.isLoadingUserProgress = false
                    // Now, check the type of error
                    if let apiError = error as? BookAPIService.APIError {
                        switch apiError {
                        case .resourceNotFound: // Check for specific error type using a switch
                            self.currentUserBookStatus = .wantToRead // Default if not on shelf
                            self.currentUserBookPage = 0 // Or nil, depending on preference
                            self.fetchErrorMessage = "Not yet on your shelf. Add it via 'Update Progress'."
                            // print("Book not found on user's shelf. Defaulting status.")
                        default:
                            self.fetchErrorMessage = apiError.localizedDescription
                            // print("Error fetching user book progress (APIError): \(apiError.localizedDescription)")
                        }
                    } else { // Catch any other errors
                        self.fetchErrorMessage = error.localizedDescription // Generic error message
                        // print("Error fetching user book progress (Unknown): \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}


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
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.1), radius: 3, y: 1)
    }
}

struct BookReviewsTabView: View {
    let book: Book
    @AppStorage("authToken") var token = ""
    @Binding var reviewText: String
    @Binding var reviewRating: Int
    @State private var reviews: [ReviewsItem] = []
    // Alert state variables
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Reviews")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.bottom, 5)
            
            ForEach(reviews, id: \.id) { i in
                ReviewCard(name: i.username, book: book.title, rating: i.rating , detail:i.description, book_id:book.id)
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
                writeReviews(book:book.id, rating:reviewRating, detail:reviewText, token:token)
                print("Submit Review tapped. Rating: \(reviewRating), Text: \(reviewText)")
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(reviewRating == 0 || reviewText.isEmpty)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.1), radius: 3, y: 1)
        .onAppear {
            fetchReviews(book:book.id, token:token)
        }.alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }    }
    func fetchReviews(book:String, token:String) {
        ReviewAPIService().GetReview(api_id: book, token: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedReviews):
                    self.reviews = fetchedReviews
                case .failure(let error):
                    print("Error fetching reviews: \(error.localizedDescription)")
                }
            }
        }
    }
    func writeReviews(book:String, rating:Int, detail:String, token:String){
            ReviewAPIService().PostReview(api_id: book, rating: rating, description: detail, token: token){ result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        alertTitle = "Success"
                        alertMessage = "Your review has been submitted."
                        showAlert = true
                        reviewText = ""
                        reviewRating = 0
                        fetchReviews(book: book, token: token)
                    case .failure(let error):
                        alertTitle = "Error"
                        alertMessage = "Failed to submit review: \(error.localizedDescription)"
                        showAlert = true
                    }
                }
            }
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
            BookDetailView(book: Book.example).environmentObject(UserSession())
        }
        .preferredColorScheme(.light)
    }
}
