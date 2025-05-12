//
//  HistoryModel.swift
//  EverRead
//
//  Created by user269706 on 5/12/25.
//

import Foundation

struct HistoryItem: Codable, Identifiable {
    let id: String
    let action: String
    let userId: String
    let bookId: String?
    let apiId: String?
    let createdAt: String
    let v: Int
    let username:String
    let daysAgo:Int
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case action
        case userId = "user_id"
        case bookId = "book_id"
        case apiId = "api_id"
        case createdAt = "created_at"
        case v = "__v"
        case username
        case daysAgo
    }
}



class HistoryAPIService {
    private let baseURL = URL(string: "https://everreadapp.onrender.com/api/history")!
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
                case .resourceNotFound: return "Review not found."
                }
            }
        }
    
    func GetHistory(token:String ,completion: @escaping (Result<[HistoryItem], APIError>) -> Void){
        guard let url = URL(string: "\(baseURL)/get") else {
            completion(.failure(.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(.failure(.resourceNotFound))
                return
            }
            // Log raw response string
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw response from server:\n\(rawResponse)")
            }
            
            do {
                let response = try JSONDecoder().decode([HistoryItem].self, from: data)
                print("Get review successful")
                // Return the successful response with user details
                completion(.success(response))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
}

