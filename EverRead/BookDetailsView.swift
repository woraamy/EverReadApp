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
    @State private var reviewText: String = ""
    @State private var reviewRating: Int = 0
    @State private var showingUpdateProgressSheet = false
    
    // These would be fetched from your backend for the current user and this book
    @State private var currentUserBookStatus: BookReadingStatus = .wantToRead
    @State private var currentUserBookPage: Int? = nil
    @State private var isLoadingUserProgress: Bool = false

    @EnvironmentObject var session: UserSession

    // (secureImageUrl function as before)
     private func secureImageUrl(_ urlString: String?) -> URL? {
        guard let urlString = urlString, !urlString.isEmpty else { return nil }
        let secureUrlString: String
        if urlString.lowercased().hasPrefix("http://") {
            secureUrlString = "https://" + urlString.dropFirst("http://".count)
        } else {
            secureUrlString = urlString
        }
        return URL(string: secureUrlString)
    }

    var body: some View {
        ZStack {
            // (Background color as before)
            Color.softWhitePink.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 15) { // Adjusted spacing
                        // (AsyncImage for book cover as before)
                        if let secureUrl = secureImageUrl(book.thumbnailUrl) {
                            AsyncImage(url: secureUrl) { phase in
                                if let image = phase.image { image.resizable().aspectRatio(contentMode: .fit).shadow(radius: 5) }
                                else if phase.error != nil { Image(systemName: "book.closed").resizable().aspectRatio(contentMode: .fit).foregroundColor(.gray).frame(height: 200).background(Color.gray.opacity(0.1)) }
                                else { ProgressView().frame(height: 200) }
                            }.frame(maxHeight: 250).padding(.top)
                        } else {
                             Image(systemName: "book.closed").resizable().aspectRatio(contentMode: .fit).foregroundColor(.gray).frame(height: 200).background(Color.gray.opacity(0.1)).padding(.top)
                        }


                        Text(book.title).font(.title2).fontWeight(.bold).multilineTextAlignment(.center).foregroundColor(.darkPinkBrown)
                        Text("by \(book.authors)").font(.headline).foregroundColor(.gray)
                        
                        // Display current user's status and progress
                        VStack {
                            if isLoadingUserProgress {
                                ProgressView()
                            } else {
                                Text("Status: \(currentUserBookStatus.displayName)")
                                if currentUserBookStatus == .currentlyReading, let page = currentUserBookPage, let total = book.pageCount, total > 0 {
                                    Text("Page: \(page) of \(total)")
                                } else if currentUserBookStatus == .currentlyReading, let page = currentUserBookPage {
                                     Text("Page: \(page)")
                                }
                            }
                        }
                        .font(.caption).foregroundColor(.black)
                        .padding(.vertical, 5).padding(.horizontal, 15)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.redPink.opacity(0.8)))


                        StarRatingView(rating: .constant(Int(book.averageRating?.rounded() ?? 0)), maxRating: 5, interactive: false)
                            .padding(.bottom, 5)
                        
                        Button("Update My Reading Progress") {
                            self.showingUpdateProgressSheet = true
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal)

                        // (Tab Buttons and Tab Content as before)
                        HStack(spacing: 0) {
                            DetailTabButton(label: "Details", detail_tab: .Detail, selectedTab: $selectedTab)
                            DetailTabButton(label: "Google Review", detail_tab: .GoogleReview, selectedTab: $selectedTab)
                        }
                        .frame(width:350, height:40 )
                        .background(Color.redPink)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.vertical, 10)

                        Group {
                            switch selectedTab {
                            case .Detail:
                                BookDetailsTabView(book: book) // Pass the book
                            case .GoogleReview:
                                BookReviewsTabView(book: book, reviewText: $reviewText, reviewRating: $reviewRating)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .sheet(isPresented: $showingUpdateProgressSheet) {
            BookStatusUpdateView(
                book: book,
                currentStatus: currentUserBookStatus, // Pass fetched status
                currentPage: currentUserBookPage,     // Pass fetched page
                onUpdateComplete: {
                    print("BookDetailView: Progress update sheet closed. Refreshing user progress.")
                    fetchUserBookProgress() // Refresh after update
                }
            )
            .environmentObject(session)
        }
        .onAppear {
            fetchUserBookProgress() // Fetch initial progress when view appears
        }
        .navigationTitle(book.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    // Function to fetch user's current progress for THIS book from your backend
    func fetchUserBookProgress() {
        // This is a placeholder. You need to implement an API call to your backend.
        // Example: GET /api/books/progress/{api_id} or similar
        // This endpoint would return the user's Book document from your MongoDB.
        isLoadingUserProgress = true
        print("Fetching user progress for book ID: \(book.id)...")
        Task {
            // Simulate API call
            // Replace this with actual API call to your backend
            // The backend should return the user's specific entry for this book (api_id)
            // which includes their 'status' and 'current_page'.
            
            // --- Placeholder for API call ---
            // For example:
            // let userBookData = try await UserSpecificBookAPIService.shared.fetchProgress(apiId: book.id, userToken: session.token)
            // self.currentUserBookStatus = BookReadingStatus(rawValue: userBookData.status) ?? .wantToRead
            // self.currentUserBookPage = userBookData.currentPage
            // --- End Placeholder ---
            
            // Simulating fetched data for now:
            // In a real app, you'd get this from your backend.
            // If book not on shelf, backend might return 404 or specific response.
            // For this example, we'll just keep the default .wantToRead / nil page.
            // If you have a way to query your `Book` model in Swift that holds user-specific data, use that.
            // For now, we assume `currentUserBookStatus` and `currentUserBookPage` are updated by this "fetch"
            
            // Example: If you had a local cache or another service
            // For demo, let's assume it's not on shelf initially unless you implement the fetch
            // self.currentUserBookStatus = .wantToRead
            // self.currentUserBookPage = 0
            
            // This function needs to be properly implemented to call your backend
            // to get the current user's saved status and page for `book.id`.
            // Upon success, update `currentUserBookStatus` and `currentUserBookPage`.
            
            try? await Task.sleep(nanoseconds: 1_000_000_000) // Simulate network delay
            isLoadingUserProgress = false
            print("Finished (simulated) fetching user progress.")
        }
    }
}


struct BookStatusUpdateView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var session: UserSession

    let book: Book
    let initialStatus: BookReadingStatus // Status when the sheet was opened
    let initialCurrentPage: Int?      // Current page when the sheet was opened
    
    @State private var selectedStatus: BookReadingStatus
    @State private var currentPageInput: String = ""
    
    @State private var isLoading: Bool = false
    @State private var alertMessage: String? = nil
    @State private var showAlert: Bool = false
    
    var onUpdateComplete: (() -> Void)?

    init(book: Book, currentStatus: BookReadingStatus, currentPage: Int?, onUpdateComplete: (() -> Void)? = nil) {
        self.book = book
        self.initialStatus = currentStatus
        self.initialCurrentPage = currentPage
        self._selectedStatus = State(initialValue: currentStatus)
        
        if let page = currentPage, page > 0 {
            self._currentPageInput = State(initialValue: "\(page)")
        } else if currentStatus == .finished, let totalPages = book.pageCount, totalPages > 0 {
            self._currentPageInput = State(initialValue: "\(totalPages)")
        } else {
            self._currentPageInput = State(initialValue: "0") // Default for want to read or new currently reading
        }
        self.onUpdateComplete = onUpdateComplete
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Update: \(book.title)")) {
                    Picker("Reading Status", selection: $selectedStatus) {
                        ForEach(BookReadingStatus.allCases) { status in
                            Text(status.displayName).tag(status)
                        }
                    }
                    .onChange(of: selectedStatus) { newStatus in
                        if newStatus == .finished, let totalPages = book.pageCount, totalPages > 0 {
                            currentPageInput = "\(totalPages)"
                        } else if newStatus == .wantToRead {
                            currentPageInput = "0"
                        }
                        // If changing to 'currently reading' and current page is 0 or empty, keep it that way or let user input
                    }

                    if selectedStatus == .currentlyReading || (selectedStatus == .finished && book.pageCount == nil) {
                        VStack(alignment: .leading) {
                            Text(selectedStatus == .finished ? "Pages Read (optional if total unknown)" : "Current Page:")
                            TextField("Enter page number", text: $currentPageInput)
                                .keyboardType(.numberPad)
                            if let pageCount = book.pageCount, pageCount > 0 {
                                Text("Total Pages: \(pageCount)")
                                    .font(.caption).foregroundColor(.gray)
                            }
                        }
                    }
                }

                Section {
                    Button(action: handleSaveProgress) {
                        HStack {
                            Spacer()
                            if isLoading { ProgressView().tint(.white) } else { Text("Save Changes") }
                            Spacer()
                        }
                    }
                    .disabled(isLoading)
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .navigationTitle("Update Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
            }
            .alert("Update Status", isPresented: $showAlert, presenting: alertMessage) { _ in
                Button("OK") { if alertMessage == "Progress updated successfully!" { dismiss() } } // Dismiss on success
            } message: { messageText in Text(messageText) }
        }
    }

    private func handleSaveProgress() {
        isLoading = true
        alertMessage = nil

        let newStatus = selectedStatus
        var newCurrentPageInt: Int? = nil
        if !currentPageInput.isEmpty {
            guard let page = Int(currentPageInput), page >= 0 else {
                finalizeUpdate(success: false, message: "Invalid page number.")
                return
            }
            newCurrentPageInt = page
        }

        // Validate page number if book has a page count
        if let totalPages = book.pageCount, totalPages > 0, let current = newCurrentPageInt {
            if current > totalPages {
                finalizeUpdate(success: false, message: "Current page (\(current)) cannot exceed total pages (\(totalPages)).")
                return
            }
        }
        
        // If status is 'finished' and page_count is known, current_page should be page_count
        if newStatus == .finished, let totalPages = book.pageCount, totalPages > 0 {
            newCurrentPageInt = totalPages // Override input if status is finished
        } else if newStatus == .wantToRead {
            newCurrentPageInt = 0 // Override for want to read
        }


        Task {
            do {
                guard let token = session.token else { throw BookAPIService.APIError.noToken }

                // Step 1: Update overall status if it changed or if it's the initial add.
                // The backend /status endpoint handles setting default current_page based on status.
                if newStatus != initialStatus || initialStatus == .wantToRead && newCurrentPageInt ?? 0 > 0 { // Heuristic: if status changed, or was 'want to read' and now has progress
                    try await BookAPIService.shared.updateBookOverallStatus(
                        book: book,
                        newStatus: newStatus,
                        userToken: token
                    )
                }

                // Step 2: If status is 'currently reading' and a specific page is set (and potentially changed),
                // or if status is 'finished' and current page needs to be set to total (handled by /status, but explicit update is fine),
                // then update the page.
                if let pageToSet = newCurrentPageInt,
                   (newStatus == .currentlyReading && pageToSet != ((initialStatus == .currentlyReading ? initialCurrentPage : 0)!)) || // Page changed for currently reading
                   (newStatus == .finished && book.pageCount != nil && pageToSet == book.pageCount) // Explicitly setting finished page
                {
                     // Only call if page is different from what /status might have set for 'currently reading' (0) or if it's a meaningful update
                    if newStatus == .currentlyReading && (pageToSet != initialCurrentPage || initialStatus != .currentlyReading) {
                         try await BookAPIService.shared.updateBookCurrentPage(
                            apiId: book.id,
                            newPage: pageToSet,
                            userToken: token
                        )
                    }
                }
                
                finalizeUpdate(success: true, message: "Progress updated successfully!")
                onUpdateComplete?()

            } catch {
                if let apiError = error as? BookAPIService.APIError {
                    finalizeUpdate(success: false, message: apiError.localizedDescription)
                } else {
                    finalizeUpdate(success: false, message: "An unexpected error occurred: \(error.localizedDescription)")
                }
                print("Error saving progress: \(error)")
            }
        }
    }
    
    private func finalizeUpdate(success: Bool, message: String) {
        isLoading = false
        alertMessage = message
        showAlert = true
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
