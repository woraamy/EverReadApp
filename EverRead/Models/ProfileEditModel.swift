//
//  ProfileEditModel.swift
//  EverRead
//
//  Created by user269706 on 5/12/25.
//

import Foundation
import UIKit

class ProfileEditAPIService {
    private let baseURL = URL(string: "https://everreadapp.onrender.com/api/profile")!
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
            let url = baseURL.appendingPathComponent("upload")
            
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
    }
