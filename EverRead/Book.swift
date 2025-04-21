//
//  Book.swift
//  EverRead
//
//  Created by Worawalan Chatlatanagulchai on 21/4/2568 BE.
//

struct Book: Identifiable, Decodable, Hashable {
    let id: String
    let volumeInfo: VolumeInfo

    // Conformance to Hashable (needed for NavigationLink value)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: Book, rhs: Book) -> Bool {
        lhs.id == rhs.id
    }

    // Convenience accessors
    var title: String { volumeInfo.title ?? "No Title" }
    var authors: String { volumeInfo.authors?.joined(separator: ", ") ?? "Unknown Author" }
    var description: String { volumeInfo.description ?? "No description available." }
    var thumbnailUrl: String? { volumeInfo.imageLinks?.thumbnail }
    var averageRating: Double? { volumeInfo.averageRating }
    var ratingsCount: Int? { volumeInfo.ratingsCount }
    var pageCount: Int? { volumeInfo.pageCount }
    var publishedDate: String? { volumeInfo.publishedDate }
    var publisher: String? { volumeInfo.publisher }

    // Example Book for Previews
    static var example: Book {
        Book(id: "preview_id_123",
             volumeInfo: VolumeInfo(
                title: "Royal Assassin",
                authors: ["Robin Hobb"],
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
//                imageLinks: ImageLinks(smallThumbnail: <#String?#>, thumbnail: "https://books.google.com/books/content?id=_CpysyfU4gMC&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api"), // Replace with a valid URL if possible for preview
                imageLinks: ImageLinks(smallThumbnail: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSptCNaQkVw3TeDewYix6nPWzLJv2YLv909Yw&s", thumbnail: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSptCNaQkVw3TeDewYix6nPWzLJv2YLv909Yw&s"),
                averageRating: 4.5,
                ratingsCount: 1250,
                pageCount: 200,
                publishedDate: "2004",
                publisher: "None"
            
             )
        )
    }
}

struct VolumeInfo: Decodable, Hashable {
    let title: String?
    let authors: [String]?
    let description: String?
    let imageLinks: ImageLinks?
    let averageRating: Double?
    let ratingsCount: Int?
    let pageCount: Int?
    let publishedDate: String?
    let publisher: String?
}

struct ImageLinks: Decodable, Hashable {
    let smallThumbnail: String?
    let thumbnail: String?
}

// Model for the overall Google Books API response
struct GoogleBooksResponse: Decodable {
    let items: [Book]?
}
