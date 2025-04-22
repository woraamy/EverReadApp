//
//  SearchView.swift
//  EverRead
//
//  Created by Worawalan Chatlatanagulchai on 21/4/2568 BE.
//

import Foundation
import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = GoogleBooksViewModel()
    @State private var searchText: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search For Books", text: $searchText)
                        .onSubmit {
                            viewModel.searchBooks(query: searchText)
                        }
                        .submitLabel(.search)
                }
                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                .background(Color.lightGrayBackground)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 10)

                if viewModel.isLoading {
                    ProgressView("Searching...")
                        .frame(maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                     Text(errorMessage)
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxHeight: .infinity)
                } else {
                    List(viewModel.searchResults) { book in
                         NavigationLink(value: book) {
                             BookRow(book: book)
                         }
                         .listRowSeparator(.hidden)
                         .listRowBackground(Color.softWhitePink)
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color.softWhitePink.ignoresSafeArea())
            .navigationTitle("Search")
            .navigationDestination(for: Book.self) { book in
                BookDetailView(book: book)
            }

        }
    }
}

// search results
struct BookRow: View {
    let book: Book
    
    // Function to ensure URL uses HTTPS
    private func secureImageUrl(_ urlString: String?) -> URL? {
        guard let urlString = urlString, !urlString.isEmpty else { return nil }
        
        // Create a proper URL with https instead of http
        let secureUrlString: String
        if urlString.lowercased().hasPrefix("http://") {
            secureUrlString = "https://" + urlString.dropFirst("http://".count)
            print("Converting \(urlString) to \(secureUrlString)")
        } else {
            secureUrlString = urlString
        }
        
        return URL(string: secureUrlString)
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // The image container with fixed dimensions
            ZStack {
                Color.gray.opacity(0.1)
                
                // The image content
                if let secureUrl = secureImageUrl(book.thumbnailUrl) {
                    AsyncImage(url: secureUrl) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        case .failure:
                            Image(systemName: "book.closed")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.gray)
                        @unknown default:
                            Image(systemName: "book.closed")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.gray)
                        }
                    }
                } else {
                    Image(systemName: "book.closed")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 50, height: 75)
            .cornerRadius(4)
            
            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.headline)
                    .foregroundColor(.darkPinkBrown)
                    .lineLimit(2)
                Text(book.authors)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    SearchView()
}
