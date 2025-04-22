//
//  GoogleBooksViewModel.swift
//  EverRead
//
//  Created by Worawalan Chatlatanagulchai on 21/4/2568 BE.
//

import Foundation
import Combine

@MainActor
class GoogleBooksViewModel: ObservableObject {
    @Published var searchResults: [Book] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var searchCancellable: AnyCancellable?
    
    struct APIConfig {
        static let googleBooksKey: String = {
            guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_BOOK_API_KEY") as? String else {
                fatalError("GOOGLE_BOOK_API_KEY not found in Info.plist")
            }
            return apiKey
        }()
    }

    func searchBooks(query: String) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.searchResults = []
            return
        }
        guard let urlEncodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            self.errorMessage = "Invalid search query"
            return
        }
        
         let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(urlEncodedQuery)&key=\(APIConfig.googleBooksKey)&maxResults=20"
//         let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(urlEncodedQuery)&maxResults=20"
        
        print(urlString)

        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid URL"
            return
        }

        isLoading = true
        errorMessage = nil

        searchCancellable?.cancel()
        
        searchCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: GoogleBooksResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    print("Search finished successfully.")
                case .failure(let error):
                    print("Search failed: \(error)")
                    self?.errorMessage = "Failed to fetch books: \(error.localizedDescription)"
                    self?.searchResults = []
                }
            }, receiveValue: { [weak self] response in
                self?.searchResults = response.items ?? []
                if self?.searchResults.isEmpty == true {
                    
                    self?.errorMessage = "No books found for '\(query)'."
                }
            })
    }

    func loadExampleData() {
        let book1 = Book.example

        let volumeInfo2 = VolumeInfo(
            title: "Another Book for Preview",
            authors: ["Author Two", "Another Author"],
            description: "This is a short description for the second example book used in previews.",
            imageLinks: nil, // Example with no image link
            averageRating: 3.5,
            ratingsCount: 45,
            pageCount: 210,
            publishedDate: "2023-05-20",
            publisher: "Example Press"
        )
        let book2 = Book(id: "preview_id_456", volumeInfo: volumeInfo2)

        self.searchResults = [book1, book2]
    }
}
