//
//  ProfileEditModel.swift
//  EverRead
//
//  Created by user269706 on 5/12/25.
//

import Foundation
import UIKit

struct EditUsernameRequest:Codable{
    let username:String
}
struct EditBioeRequest:Codable{
    let bio:String
}

struct EditYearlyGoalRequest: Codable {
    let yearly_goal: Int
}

struct EditMonthGoalRequest: Codable {
    let month_goal: Int
}

class ProfileEditAPIService {
    private let baseURL = URL(string: "https://everreadapp.onrender.com/api")!
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
                case .resourceNotFound: return "Failed to convert image to data.."
                }
            }
        }
    func uploadProfileImage(image: UIImage, userToken: String, completion: @escaping (Result<Data, APIError>) -> Void) {
            let url = baseURL.appendingPathComponent("profile/upload")
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                completion(.failure(.resourceNotFound))
                return
            }

            var body = Data()
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"profile\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

            URLSession.shared.uploadTask(with: request, from: body) { responseData, response, error in
                if let error = error {
                    completion(.failure(.requestFailed(error)))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponse))
                    return
                }

                if (200...299).contains(httpResponse.statusCode) {
                    if let responseData = responseData {
                        completion(.success(responseData))
                    } else {
                        completion(.failure(.invalidResponse))
                    }
                } else {
                    let message = String(data: responseData ?? Data(), encoding: .utf8)
                    completion(.failure(.statusCode(httpResponse.statusCode, message)))
                }
            }.resume()
        }

        func SubmitProfileEdit(username: String, bio: String, token: String, completion: @escaping (Result<Void, APIError>) -> Void) {
            let group = DispatchGroup()
            var errors: [APIError] = []

            func makeRequest(endpoint: String, body: Data) {
                guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
                    errors.append(.invalidURL)
                    return
                }

                var request = URLRequest(url: url)
                request.httpMethod = "PUT"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                request.httpBody = body

                group.enter()
                URLSession.shared.dataTask(with: request) { data, response, error in
                    defer { group.leave() }

                    if let error = error {
                        errors.append(.requestFailed(error))
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse else {
                        errors.append(.invalidResponse)
                        return
                    }

                    if !(200...299).contains(httpResponse.statusCode) {
                        let message = data.flatMap { String(data: $0, encoding: .utf8) }
                        errors.append(.statusCode(httpResponse.statusCode, message))
                    }
                }.resume()
            }

            if !username.isEmpty {
                let body = EditUsernameRequest(username: username)
                do {
                    let encoded = try JSONEncoder().encode(body)
                    makeRequest(endpoint: "profile/name", body: encoded)
                } catch {
                    completion(.failure(.encodingError(error)))
                    return
                }
            }

            if !bio.isEmpty {
                let body = EditBioeRequest(bio: bio)
                do {
                    let encoded = try JSONEncoder().encode(body)
                    makeRequest(endpoint: "profile/bio", body: encoded)
                } catch {
                    completion(.failure(.encodingError(error)))
                    return
                }
            }

            group.notify(queue: .main) {
                if errors.isEmpty {
                    completion(.success(()))
                } else {
                    completion(.failure(errors.first!)) 
                }
            }
        }

    func submitYearlyGoal(goal: Int, token: String, completion: @escaping (Result<Void, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/goal/year") else {
            completion(.failure(.invalidURL))
            return
        }

        let body = EditYearlyGoalRequest(yearly_goal: goal)
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(.encodingError(error)))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                completion(.success(()))
            } else {
                let message = data.flatMap { String(data: $0, encoding: .utf8) }
                completion(.failure(.statusCode(httpResponse.statusCode, message)))
            }
        }.resume()
    }
    func submitMonthGoal(goal: Int, token: String, completion: @escaping (Result<Void, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/goal/month") else {
            completion(.failure(.invalidURL))
            return
        }

        let body = EditMonthGoalRequest(month_goal: goal)
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(.encodingError(error)))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                completion(.success(()))
            } else {
                let message = data.flatMap { String(data: $0, encoding: .utf8) }
                completion(.failure(.statusCode(httpResponse.statusCode, message)))
            }
        }.resume()
    }

        

    }
