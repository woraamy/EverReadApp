
import Foundation

enum BookReadingStatus: String, CaseIterable, Identifiable, Codable {
    case wantToRead = "want to read"
    case currentlyReading = "currently reading"
    case finished = "finished"

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .wantToRead: return "Want to Read"
        case .currentlyReading: return "Currently Reading"
        case .finished: return "Finished"
        }
    }
}

// Request structure for updating book's OVERALL STATUS
struct UpdateBookOverallStatusRequest: Codable {
    let api_id: String
    let name: String
    let author: String
    let page_count: Int?
    let status: String
}

// Request structure for updating book's CURRENT PAGE
struct UpdateBookCurrentPageRequest: Codable {
    let api_id: String
    let current_page: Int
}

// Response structure for fetching user's specific book progress from your backend
struct UserBookProgressResponse: Codable, Identifiable {
    let id: String // MongoDB _id
    let api_id: String
    let user_id: String
    let name: String
    let author: String
    let page_count: Int?
    let current_page: Int?
    let status: BookReadingStatus

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case api_id, user_id, name, author, page_count, current_page, status
    }
}

// Represents an entry from your backend's shelf listing
struct UserBookEntry: Codable, Identifiable {
    let id: String
    let api_id: String
    let user_id: String
    let name: String
    let author: String
    let page_count: Int?
    let current_page: Int?
    let status: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case api_id, user_id, name, author, page_count, current_page, status
    }
}


// MARK: - API Service (Corrected)

class BookAPIService {
    private let baseURL = URL(string: "https://everreadapp.onrender.com/api/books/progress")!
    
    struct APIConfig {
        static let googleBooksKey: String = {
            guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_BOOK_API_KEY") as? String else {
                fatalError("GOOGLE_BOOK_API_KEY not found in Info.plist")
            }
            return apiKey
        }()
    }

    enum APIError: Error, LocalizedError {
        
        
        
        case invalidURL, requestFailed(Error), invalidResponse, statusCode(Int, String?), decodingError(Error), encodingError(Error), noToken, resourceNotFound
        var errorDescription: String? {
            switch self {
            case .invalidURL: return "Invalid server URL."
            case .requestFailed(let error): return "Request failed: \(error.localizedDescription)."
            case .invalidResponse: return "Invalid response from server."
            case .statusCode(let code, let msg): return "Server error \(code)." + (msg.map { " \($0)" } ?? "")
            case .decodingError(let error): return "Failed to decode response: \(error.localizedDescription)."
            case .encodingError(let error): return "Failed to encode request: \(error.localizedDescription)."
            case .noToken: return "Authentication token missing."
            case .resourceNotFound: return "Book not found on your shelf."
            }
        }
    }
    


    static let shared = BookAPIService()
    private init() {}

    func updateBookOverallStatus(book: Book, newStatus: BookReadingStatus, userToken: String?) async throws -> UserBookProgressResponse {
        guard let token = userToken, !token.isEmpty else { throw APIError.noToken }
        let url = baseURL.appendingPathComponent("status")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let requestBody = UpdateBookOverallStatusRequest(api_id: book.id, name: book.title, author: book.authors, page_count: book.pageCount, status: newStatus.rawValue)
        do { request.httpBody = try JSONEncoder().encode(requestBody) } catch { throw APIError.encodingError(error) }
        return try await performAPIPostRequest(request: request, decodingType: UserBookProgressResponse.self)
    }

    func updateBookCurrentPage(apiId: String, newPage: Int, userToken: String?) async throws -> UserBookProgressResponse {
        guard let token = userToken, !token.isEmpty else { throw APIError.noToken }
        let url = baseURL.appendingPathComponent("page") // This calls the /page route
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let requestBody = UpdateBookCurrentPageRequest(api_id: apiId, current_page: newPage)
        do { request.httpBody = try JSONEncoder().encode(requestBody) } catch { throw APIError.encodingError(error) }
        return try await performAPIPostRequest(request: request, decodingType: UserBookProgressResponse.self)
    }
    
    func fetchUserBookProgress(apiId: String, userToken: String?) async throws -> UserBookProgressResponse {
        guard let token = userToken, !token.isEmpty else {
            throw APIError.noToken
        }
        let url = baseURL.appendingPathComponent(apiId) // GET /api/books/progress/{api_id}
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await performAPIGetRequest(request: request, decodingType: UserBookProgressResponse.self)
    }
    
    
    
    private func performAPIPostRequest<T: Decodable>(request: URLRequest, decodingType: T.Type) async throws -> T {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { throw APIError.invalidResponse }
            if !(200...299).contains(httpResponse.statusCode) {
                var errMsg: String? = nil; if let json = try? JSONSerialization.jsonObject(with: data) as? [String:Any] { if let m = json["msg"] as? String {errMsg=m} else if let e = json["error"] as? String {errMsg=e} }; throw APIError.statusCode(httpResponse.statusCode, errMsg)
            }
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error as APIError { throw error }
        catch let decodingError as DecodingError { print("Decoding error details: \(decodingError)"); throw APIError.decodingError(decodingError) }
        catch { throw APIError.requestFailed(error) }
    }

    private func performAPIGetRequest<T: Decodable>(request: URLRequest, decodingType: T.Type) async throws -> T {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { throw APIError.invalidResponse }
            if httpResponse.statusCode == 404 { throw APIError.resourceNotFound }
            if !(200...299).contains(httpResponse.statusCode) {
                var errMsg: String? = nil; if let json = try? JSONSerialization.jsonObject(with: data) as? [String:Any] { if let m = json["msg"] as? String {errMsg=m} else if let e = json["error"] as? String {errMsg=e} }; throw APIError.statusCode(httpResponse.statusCode, errMsg)
            }
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error as APIError { throw error }
        catch let decodingError as DecodingError { print("Decoding error details: \(decodingError)"); throw APIError.decodingError(decodingError) }
        catch { throw APIError.requestFailed(error) }
    }
    

    /**
     Fetches detailed book information for a single book from Google Books API using its volume ID.
     - Parameter googleBookId: The Google Books Volume ID (this is your `api_id`).
     - Returns: A `Book` object containing full volume information.
     - Throws: `APIError` if the request fails, decoding fails, or the API key is not set.
     */
    private func fetchGoogleBookDetailsBy(googleBookId: String) async throws -> Book {

        guard var components = URLComponents(string: "https://www.googleapis.com/books/v1/volumes/\(googleBookId)") else {
            throw APIError.invalidURL
        }
        components.queryItems = [URLQueryItem(name: "key", value: APIConfig.googleBooksKey)]

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 404 {
            print("Book with ID \(googleBookId) not found on Google Books.")
            throw APIError.resourceNotFound
        }
        if !(200...299).contains(httpResponse.statusCode) {
            var errMsg: String?
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorDict = json["error"] as? [String: Any],
               let message = errorDict["message"] as? String {
                errMsg = message
            }
            print("Google Books API error for ID \(googleBookId): \(httpResponse.statusCode) - \(errMsg ?? "No message")")
            throw APIError.statusCode(httpResponse.statusCode, "Google Books API: \(errMsg ?? "Unknown error")")
        }

        do {
            let book = try JSONDecoder().decode(Book.self, from: data)
            return book
        } catch let decodingError as DecodingError {
            print("Google Books Decoding Error for ID \(googleBookId): \(decodingError)")
            throw APIError.decodingError(decodingError)
        } catch {
            print("Unknown error decoding Google Book ID \(googleBookId): \(error)")
            throw APIError.requestFailed(error)
        }
    }

    /**
     Fetches a list of `UserBookEntry` from your backend for a given shelf,
     then fetches full `Book` details for each entry from Google Books API.
     - Parameter shelfPath: The path component for the shelf (e.g., "currently-reading", "want-to-read").
     - Parameter userToken: The user's authentication token for your backend.
     - Returns: An array of `Book` objects with full details.
     - Throws: `APIError` if any step fails.
     */
    private func fetchShelfBooksWithDetails(shelfPath: String, userToken: String?) async throws -> [Book] {
        guard let token = userToken, !token.isEmpty else {
            throw APIError.noToken
        }

        // The URL should be like: http://localhost:5050/api/books/progress/shelf/currently-reading
        let entriesUrl = baseURL.appendingPathComponent("shelf/\(shelfPath)")
        print(entriesUrl)
        var entriesRequest = URLRequest(url: entriesUrl)
        entriesRequest.httpMethod = "GET"
        entriesRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        entriesRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        let userBookEntries: [UserBookEntry] = try await performAPIGetRequest(request: entriesRequest, decodingType: [UserBookEntry].self)

        if userBookEntries.isEmpty {
            return [] 
        }

        var detailedBooks: [Book] = []
        
        try await withThrowingTaskGroup(of: Book?.self) { group in
            for entry in userBookEntries {
                group.addTask {
                    do {
                        let detailedBook = try await self.fetchGoogleBookDetailsBy(googleBookId: entry.api_id)
                        return detailedBook
                    } catch {
                        print("Failed to fetch details for book ID \(entry.api_id) from Google Books: \(error.localizedDescription). Using fallback data from backend.")
                        
                        let fallbackVolumeInfo = VolumeInfo(
                            id: entry.id,
                            title: entry.name,
                            authors: [],
                            description: nil,
                            imageLinks: ImageLinks(smallThumbnail: "", thumbnail: ""),
                            averageRating: 0.0,
                            ratingsCount: nil,
                            pageCount: nil,
                            publishedDate: nil,
                            publisher: nil
                        )
                        return Book(id: entry.api_id, volumeInfo: fallbackVolumeInfo)
                    }
                }
            }
            
            for try await bookResult in group {
                if let book = bookResult {
                    detailedBooks.append(book)
                }
            }
        }
        
        return detailedBooks
    }
    
    private func fetchBooksFromShelf(shelfPath: String, userToken: String?) async throws -> [Book] {
            guard let token = userToken, !token.isEmpty else {
                throw APIError.noToken
            }

            // Construct the URL. Base URL should point to your server's /api/books/progress/
            // e.g., http://localhost:5050/api/books/progress/shelf/currently-reading
            let url = baseURL.appendingPathComponent("shelf/\(shelfPath)")
            print("Fetching from URL: \(url.absoluteString)")

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            return try await performAPIGetRequest(request: request, decodingType: [Book].self)
        }

        // Public method to fetch "Currently Reading" books
        func fetchCurrentlyReadingBooks(userToken: String?) async throws -> [Book] {
            try await fetchShelfBooksWithDetails(shelfPath: "currently-reading", userToken: userToken)
        }

        // Public method to fetch "Want to Read" books
        func fetchWantToReadBooks(userToken: String?) async throws -> [Book] {
            try await fetchShelfBooksWithDetails(shelfPath: "want-to-read", userToken: userToken)
        }
    
        // Public method to fetch "Finished" books
        func fetchFinishedBooks(userToken: String?) async throws -> [Book] {
            try await fetchShelfBooksWithDetails(shelfPath: "finished", userToken: userToken)
        }
}
