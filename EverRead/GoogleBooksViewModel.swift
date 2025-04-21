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

    private let apiKey = "AIzaSyBF3jFvIKnQSBeeNQ7QboTKzKHPDhoFqTw"
    private var searchCancellable: AnyCancellable?

    func searchBooks(query: String) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.searchResults = []
            return
        }
        guard let urlEncodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            self.errorMessage = "Invalid search query"
            return
        }

//         let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(urlEncodedQuery)&key=\(apiKey)&maxResults=20"
         let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(urlEncodedQuery)&maxResults=20"

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
            .receive(on: DispatchQueue.main) // Switch back to main thread for UI updates
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    print("Search finished successfully.")
                case .failure(let error):
                    print("Search failed: \(error)")
                    self?.errorMessage = "Failed to fetch books: \(error.localizedDescription)"
                    self?.searchResults = [] // Clear results on failure
                }
            }, receiveValue: { [weak self] response in
                self?.searchResults = response.items ?? []
                if self?.searchResults.isEmpty == true {
                    self?.errorMessage = "No books found for '\(query)'."
                }
            })
    }

    func loadExampleData() {
         self.searchResults = [Book.example, Book(id: "preview_id_456", volumeInfo: VolumeInfo(title: "Another Book", authors: ["Author Two"], description: "Short description.", imageLinks: nil, averageRating: 3.0, ratingsCount: 50))]
    }
}
