//
//  FollowModel.swift
//  EverRead
//
//  Created by user269706 on 5/12/25.
//

import Foundation

struct FollowRespond:Codable{
    let message:String
    let following_user:String
    let followed_user:String
}
struct FollowRequest:Codable{
    let followed_user_id:String
}

struct UnfollowRespond:Codable{
    let message:String
    let following_user:String
    let followed_user:String
}
struct UnfollowRequest:Codable{
    let followed_user_id:String
}
struct isFollowingRespond:Codable{
    let isFollowing:Bool
}

class FollowAPIService {
    private let baseURL = URL(string: "https://everreadapp.onrender.com/api/follower")!
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
    
    func follow(user_id:String, token: String, completion: @escaping (Result<FollowRespond, APIError>) -> Void) {
            guard let url = URL(string: "\(baseURL)/follow") else {
                completion(.failure(.invalidURL))
                return
            }

        let body = FollowRequest(followed_user_id: user_id)

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                completion(.failure(.encodingError(error)))
                return
            }

            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(.failure(.requestFailed(error)))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponse))
                    return
                }

                guard let data = data else {
                    completion(.failure(.invalidResponse))
                    return
                }

                // Debug: Print raw response
                if let raw = String(data: data, encoding: .utf8) {
                    print("Server response:\n\(raw)")
                }

                if (200...299).contains(httpResponse.statusCode) {
                    do {
                        let response = try JSONDecoder().decode(FollowRespond.self, from: data)
                        completion(.success(response))
                    } catch {
                        completion(.failure(.decodingError(error)))
                    }
                } else {
                    let message = String(data: data, encoding: .utf8)
                    completion(.failure(.statusCode(httpResponse.statusCode, message)))
                }
            }.resume()
        }
    func unfollow(user_id:String, token: String, completion: @escaping (Result<UnfollowRespond, APIError>) -> Void) {
            guard let url = URL(string: "\(baseURL)/unfollow") else {
                completion(.failure(.invalidURL))
                return
            }

        let body = UnfollowRequest(followed_user_id: user_id)

            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                completion(.failure(.encodingError(error)))
                return
            }

            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(.failure(.requestFailed(error)))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponse))
                    return
                }

                guard let data = data else {
                    completion(.failure(.invalidResponse))
                    return
                }

                // Debug: Print raw response
                if let raw = String(data: data, encoding: .utf8) {
                    print("Server response:\n\(raw)")
                }

                if (200...299).contains(httpResponse.statusCode) {
                    do {
                        let response = try JSONDecoder().decode(UnfollowRespond.self, from: data)
                        completion(.success(response))
                    } catch {
                        completion(.failure(.decodingError(error)))
                    }
                } else {
                    let message = String(data: data, encoding: .utf8)
                    completion(.failure(.statusCode(httpResponse.statusCode, message)))
                }
            }.resume()
        }
    func isFollowing(user_id:String, token:String ,completion: @escaping (Result<isFollowingRespond, APIError>) -> Void){
        guard let url = URL(string: "\(baseURL)/isFollowing?followed_user_id=\(user_id)") else {
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
                let response = try JSONDecoder().decode(isFollowingRespond.self, from: data)
                print("Get is following successful")
                // Return the successful response with user details
                completion(.success(response))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }}
