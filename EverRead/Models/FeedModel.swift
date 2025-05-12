//
//  FeedModel.swift
//  EverRead
//
//  Created by user269706 on 5/12/25.
//

import Foundation

struct FeedHistoryItem: Codable, Identifiable {
    let id: String
    let action: String
    let userId: String
    let bookId: String?
    let apiId: String?
    let createdAt: String
    let v: Int
    let username:String
    let daysAgo:Int
    let profile:String
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
        case profile 
    }
}


struct FeedReviewsItem: Codable, Identifiable {
    let id: String
    let userId: String
    let apiId: String
    let rating: Int
    let description: String
    let createdAt: String
    let v: Int
    let bookName:String
    let username:String
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId = "user_id"
        case apiId = "api_id"
        case rating
        case description
        case createdAt = "created_at"
        case v = "__v"
        case bookName = "book_name"
        case username
    }
}

class FeedAPIService {
    private let baseURL = URL(string: "https://everreadapp.onrender.com/api/feed")!
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
    func GetFeedReview(token:String ,completion: @escaping (Result<[FeedReviewsItem], APIError>) -> Void){
        guard let url = URL(string: "\(baseURL)/getReview") else {
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
                let response = try JSONDecoder().decode([FeedReviewsItem].self, from: data)
                print("Get review successful")
                // Return the successful response with user details
                completion(.success(response))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    func GetFeedHistory(token:String ,completion: @escaping (Result<[FeedHistoryItem], APIError>) -> Void){
        guard let url = URL(string: "\(baseURL)/getHistory") else {
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
                let response = try JSONDecoder().decode([FeedHistoryItem].self, from: data)
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

