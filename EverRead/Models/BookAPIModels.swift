// File: Models/BookAPIModels.swift (Ensure this is consistent with previous versions)
import Foundation

// Represents the status options for the API and Picker
enum BookReadingStatus: String, CaseIterable, Identifiable, Codable {
    case defaultStatus = "pick a status"
    case wantToRead = "want to read"
    case currentlyReading = "currently reading"
    case finished = "finished"

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .defaultStatus: return "Pick a Status"
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


// MARK: - API Service (Corrected)

class BookAPIService {
    private let baseURL = URL(string: "http://localhost:5050/api/books/progress")!

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
            print(decodingType)
            print(request)
            let (data, response) = try await URLSession.shared.data(for: request)
            print(response)
            print(data)
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
}
