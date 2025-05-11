import Foundation

struct PostReviewRespond:Codable{
    let message:String
    let bookAPIId:String
    let ReviewId:String
    let Reviewer:String
    let rating:Int
    let description:String
}
struct PostReviewRequest:Codable{
    let api_id:String
    let rating:Int
    let description:String
}

struct ReviewsItem: Codable {
    let id: String
    let userId: String
    let apiId: String
    let rating: Int
    let description: String
    let createdAt: String
    let v: Int

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId = "user_id"
        case apiId = "api_id"
        case rating
        case description
        case createdAt = "created_at"
        case v = "__v"
    }
}

struct GetReviewRequest:Codable{
    let api_id:String
}

class ReviewAPIService {
    private let baseURL = URL(string: "https://everreadapp.onrender.com/api/review")!
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
    func GetReview(api_id:String, token:String ,completion: @escaping (Result<[ReviewsItem], APIError>) -> Void){
        guard let url = URL(string: "\(baseURL)/get?api_id=\(api_id)") else {
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
                let response = try JSONDecoder().decode([ReviewsItem].self, from: data)
                print("Get review successful")
                // Return the successful response with user details
                completion(.success(response))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    func PostReview(api_id: String, rating: Int, description: String, token: String, completion: @escaping (Result<PostReviewRespond, APIError>) -> Void) {
            guard let url = URL(string: "\(baseURL)/post") else {
                completion(.failure(.invalidURL))
                return
            }

            let body = PostReviewRequest(api_id: api_id, rating: rating, description: description)

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
                        let response = try JSONDecoder().decode(PostReviewRespond.self, from: data)
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
}

