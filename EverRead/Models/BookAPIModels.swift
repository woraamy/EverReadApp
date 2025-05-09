//
//  BookAPIModels.swift
//  EverRead
//
//  Created by Worawalan Chatlatanagulchai on 9/5/2568 BE.
//

import Foundation

// Represents the status options for the API and Picker
enum BookReadingStatus: String, CaseIterable, Identifiable {
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
    let status: String // Raw value from BookReadingStatus
}

// Request structure for updating book's CURRENT PAGE
struct UpdateBookCurrentPageRequest: Codable {
    let api_id: String
    let current_page: Int
}

// Your existing Book struct (from Google Books API) - ensure it's defined as before
/*
struct Book: Identifiable, Decodable, Hashable {
    let id: String // Google Books API ID
    let title: String
    let authors: [String]
    let pageCount: Int?
    // ... other properties ...
    var authorsConcatenated: String { authors.join(separator: ", ") }
    static var example = Book(...) // Your example book
}
*/

// Your UserSession class - ensure it has a 'token' property
/*
class UserSession: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var token: String? = nil
    // ... other properties and methods ...
}
*/


// MARK: - API Service (Updated)

class BookAPIService {
    private let baseURL = URL(string: "http://localhost:5050/api/books/progress")! // Base for progress routes

    // APIError enum (as defined previously)
    enum APIError: Error, LocalizedError {
        case invalidURL, requestFailed(Error), invalidResponse, statusCode(Int, String?), decodingError(Error), encodingError(Error), noToken
        var errorDescription: String? {
            switch self {
            case .invalidURL: return "Invalid server URL."
            case .requestFailed(let error): return "Request failed: \(error.localizedDescription)."
            case .invalidResponse: return "Invalid response from server."
            case .statusCode(let code, let msg): return "Server error \(code)." + (msg.map { " \($0)" } ?? "")
            case .decodingError: return "Failed to decode response."
            case .encodingError: return "Failed to encode request."
            case .noToken: return "Authentication token missing."
            }
        }
    }

    static let shared = BookAPIService()
    private init() {}

    // Method to update the book's overall status
    func updateBookOverallStatus(
        book: Book,
        newStatus: BookReadingStatus,
        userToken: String?
    ) async throws /* -> BackendBookModel? */ {
        guard let token = userToken, !token.isEmpty else { throw APIError.noToken }

        let url = baseURL.appendingPathComponent("status") // POST /api/books/progress/status
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let requestBody = UpdateBookOverallStatusRequest(
            api_id: book.id,
            name: book.title,
            author: book.authors,
            page_count: book.pageCount,
            status: newStatus.rawValue
        )
        
        // print("BookAPIService: Updating status for \(book.id) to \(newStatus.rawValue)")

        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            throw APIError.encodingError(error)
        }

        try await performAPIPostRequest(request: request)
    }

    // Method to update the book's current page
    func updateBookCurrentPage(
        apiId: String,
        newPage: Int,
        userToken: String?
    ) async throws /* -> BackendBookModel? */ {
        guard let token = userToken, !token.isEmpty else { throw APIError.noToken }

        let url = baseURL.appendingPathComponent("page") // POST /api/books/progress/page
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let requestBody = UpdateBookCurrentPageRequest(api_id: apiId, current_page: newPage)
        
        // print("BookAPIService: Updating page for \(apiId) to \(newPage)")

        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            throw APIError.encodingError(error)
        }
        
        try await performAPIPostRequest(request: request)
    }
    
    // Helper for actual request execution and basic response handling
    private func performAPIPostRequest(request: URLRequest) async throws /* -> BackendBookModel? */ {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            // print("BookAPIService: Status Code: \(httpResponse.statusCode)")
            // if let responseDataString = String(data: data, encoding: .utf8) {
            //     print("BookAPIService: Response Data: \(responseDataString)")
            // }

            if !(200...299).contains(httpResponse.statusCode) {
                var errorMessageFromServer: String? = nil
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                     if let msg = json["msg"] as? String { errorMessageFromServer = msg }
                     else if let errorMsg = json["error"] as? String { errorMessageFromServer = errorMsg }
                     else if let errorsArray = json["errors"] as? [[String: String]], let firstError = errorsArray.first?["msg"] { errorMessageFromServer = firstError }
                     else if let errorsArray = json["errors"] as? [String], let firstError = errorsArray.first { errorMessageFromServer = firstError }
                }
                throw APIError.statusCode(httpResponse.statusCode, errorMessageFromServer)
            }
            // Optionally decode and return backend response if needed
            // let backendBook = try JSONDecoder().decode(BackendBookModel.self, from: data)
            // return backendBook
        } catch let specificError as APIError {
            throw specificError
        } catch {
            throw APIError.requestFailed(error)
        }
    }
}
