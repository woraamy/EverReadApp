
import SwiftUI

enum ShelfTab{
    case Current
    case Want
    case Finish
}

struct MyShelfView: View {
    @StateObject private var viewModel = MyShelfViewModel()
    @EnvironmentObject var session: UserSession
    
    @State private var selectedTab: ShelfTab
    
   init(initialTab: ShelfTab = .Current) {
       self._selectedTab = State(initialValue: initialTab)
   }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.softWhitePink.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 15) { // Added some default spacing
                    Text("My Shelves")
                        .font(.largeTitle) // Slightly larger for emphasis
                        .fontWeight(.bold)
                        .padding([.horizontal, .top]) // Add padding around title

                    HStack(spacing: 5) { // Spacing for TabButtons
                        TabButton(label: "Reading", tab: .Current, selectedTab: $selectedTab)
                        TabButton(label: "Want to Read", tab: .Want, selectedTab: $selectedTab)
                        TabButton(label: "Finished", tab: .Finish, selectedTab: $selectedTab)
                    }
                    .frame(maxWidth: .infinity) // Allow HStack to expand
                    .padding(.horizontal) // Horizontal padding for the tab bar container
                    .frame(height: 50) // Explicit height for tab bar
                    .background(Color.redPink)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.bottom, 10)
                    .padding(.horizontal) // Consistent padding with title

                    if let errorMessage = viewModel.errorMessage {
                         Text(errorMessage)
                             .foregroundColor(.red)
                             .padding()
                             .frame(maxWidth: .infinity, alignment: .center)
                     }

                    Group {
                        switch selectedTab {
                        case .Current:
                            BookShelfContentView(
                                books: viewModel.currentlyReadingBooks,
                                isLoading: viewModel.isLoadingCurrent,
                                shelfTitle: "Currently Reading" // Match for getStatus
                            )
                        case .Want:
                            BookShelfContentView(
                                books: viewModel.wantToReadBooks,
                                isLoading: viewModel.isLoadingWant,
                                shelfTitle: "Want to Read" // Match for getStatus
                            )
                        case .Finish:
                            BookShelfContentView(
                                books: viewModel.finishedBooks,
                                isLoading: viewModel.isLoadingFinish,
                                shelfTitle: "Finished Reading" // Match for getStatus
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure content view takes space
                    
                }
                // .padding(30) // This padding was on the VStack, might be too much, apply selectively.
                .frame(maxWidth:.infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .onAppear {
                // Fetch data for the initially selected tab
                viewModel.loadInitialData(token: session.token, initialTab: selectedTab)
            }
            .onChange(of: selectedTab) { oldValue, newValue in
                // Fetch data for the newly selected tab
                viewModel.fetchBooks(for: newValue, token: session.token)
            }
        }
    }
}


struct BookShelfContentView: View {
    let books: [Book]
    let isLoading: Bool
    let shelfTitle: String

    private let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 20), count: 3)

    private func getStatus(forShelf title: String) -> String {
        switch title.lowercased() {
        case "currently reading": return "current"
        case "want to read": return "want"
        case "finished reading": return "finish"
        default: return ""
        }
    }

    private func getProgress(status: String) -> Int {
        if status == "current" {
            return 50
        } else if status == "finish" {
            return 100
        }
        return 0
    }

    var body: some View {
        let currentStatus = getStatus(forShelf: shelfTitle)

        if isLoading {
            VStack {
                Spacer()
                ProgressView("Loading \(shelfTitle)...")
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if books.isEmpty {
            VStack {
                Spacer()
                Text("No books on your '\(shelfTitle)' shelf yet.")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text("Add some books to get started!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 25) {
                    ForEach(books) { bookItem in
                        NavigationLink(destination: BookDetailView(book: bookItem)) {
                            BookCard(
                                status: currentStatus,
                                img: bookItem.thumbnailUrl ?? "",
                                name: bookItem.title,
                                author: bookItem.authors,
                                progress: getProgress(status: currentStatus)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
        }
    }
}



@MainActor
class MyShelfViewModel: ObservableObject {
    @Published var currentlyReadingBooks: [Book] = [] // Now [Book]
    @Published var wantToReadBooks: [Book] = []     // Now [Book]
    @Published var finishedBooks: [Book] = []       // Now [Book]

    @Published var isLoadingCurrent: Bool = false
    @Published var isLoadingWant: Bool = false
    @Published var isLoadingFinish: Bool = false
    
    @Published var errorMessage: String? = nil

    private let apiService = BookAPIService.shared

    func fetchBooks(for shelf: ShelfTab, token: String?) {
        guard let validToken = token, !validToken.isEmpty else {
            print("MyShelfViewModel: User token not available.")
            errorMessage = "User token not available. Please log in."
            clearBooksForShelf(shelf)
            return
        }
        errorMessage = nil

        switch shelf {
        case .Current:
            isLoadingCurrent = true
            Task {
                defer { isLoadingCurrent = false }
                do {
                    // Call the method that returns [Book]
                    currentlyReadingBooks = try await apiService.fetchCurrentlyReadingBooks(userToken: validToken)
                    print("Fetched \(currentlyReadingBooks.count) currently reading books for shelf.")
                } catch {
                    print("Error fetching currently reading books for shelf: \(error.localizedDescription)")
                    errorMessage = "Failed to load 'Currently Reading' books: \(error.localizedDescription)"
                    currentlyReadingBooks = []
                }
            }
        case .Want:
            isLoadingWant = true
            Task {
                defer { isLoadingWant = false }
                do {
                    // Call the method that returns [Book]
                    wantToReadBooks = try await apiService.fetchWantToReadBooks(userToken: validToken)
                    print("Fetched \(wantToReadBooks.count) want to read books for shelf.")
                } catch {
                    print("Error fetching want to read books for shelf: \(error.localizedDescription)")
                    errorMessage = "Failed to load 'Want to Read' books: \(error.localizedDescription)"
                    wantToReadBooks = []
                }
            }
        case .Finish:
            isLoadingFinish = true
            Task {
                defer { isLoadingFinish = false }
                do {
                    // Call the method that returns [Book]
                    finishedBooks = try await apiService.fetchFinishedBooks(userToken: validToken)
                    print("Fetched \(finishedBooks.count) finished books for shelf.")
                } catch {
                    print("Error fetching finished books for shelf: \(error.localizedDescription)")
                    errorMessage = "Failed to load 'Finished' books: \(error.localizedDescription)"
                    finishedBooks = []
                }
            }
        }
    }
    
    private func clearBooksForShelf(_ shelf: ShelfTab) {
        switch shelf {
        case .Current:
            currentlyReadingBooks = []
        case .Want:
            wantToReadBooks = []
        case .Finish:
            finishedBooks = []
        }
    }
    
    func loadInitialData(token: String?, initialTab: ShelfTab = .Current) {
        fetchBooks(for: initialTab, token: token)
    }
}

struct MyShelf_Previews: PreviewProvider {
    static var previews: some View {
        MyShelfView()
            .environmentObject(UserSession())
    }
}
