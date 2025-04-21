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

    var body: some View {
        HStack(spacing: 15) {
            AsyncImage(url: URL(string: book.thumbnailUrl ?? "")) { phase in
                if let image = phase.image {
                    image.resizable()
                         .aspectRatio(contentMode: .fit)
                } else if phase.error != nil {
                    Image(systemName: "book.closed") 
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                } else {
                    ProgressView()
                }
            }
            .frame(width: 50, height: 75)
            .background(Color.gray.opacity(0.1))

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
