import Foundation

enum AuthenticationError: Error {
    case invalidCredentials
    case custom(errorMessage: String)
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
}

struct LoginRequestBody: Codable {
    let email: String
    let password: String
}

struct SignupRequestBody: Codable {
    let email: String
    let username: String
    let password: String
    let correctpassword: String
}


struct User: Codable {
    let id: String
    let email: String
    let username: String
}

// This struct represents the top-level response.
struct LoginResponse: Codable {
    let token: String?
    let user: User?
    let success: Bool?
}


struct SignupResponse:  Codable {
    let message: String?
    let userId : String?
    let username : String?
    let email : String?
    let success: Bool?
}


class AuthenticationService {
    func signin(email: String, password: String, completion: @escaping (Result<(User, String), AuthenticationError>) -> Void) {
            
            // URL for login endpoint
            guard let url = URL(string: "https://everreadapp.onrender.com/api/auth/login") else {
                completion(.failure(.custom(errorMessage: "URL is not correct")))
                return
            }
            
            // Create the body for the request
            let body = LoginRequestBody(email: email, password: password)
            
            // Prepare the URLRequest
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONEncoder().encode(body)
            
            // Make the network request
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                // Handle potential errors
                guard let data = data, error == nil else {
                    completion(.failure(.custom(errorMessage: "No data or network error")))
                    return
                }
                // Log raw response string
                        if let rawResponse = String(data: data, encoding: .utf8) {
                            print("Raw response from server:\n\(rawResponse)")
                        }
                // Try to decode the response
                guard let loginResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) else {
                    completion(.failure(.invalidCredentials))
                    return
                }
                
                // Handle the success response
                guard let user = loginResponse.user else {
                    completion(.failure(.invalidCredentials)) // No user data in response
                    return
                }
                
                // If there is a token, you can use it as needed
                guard let token = loginResponse.token else {
                    completion(.failure(.invalidCredentials)) // No user data in response
                    return
                }
                
                // Return the User data if successful
                completion(.success((user,token)))
                
            }.resume()
        }
    
    func signup(email: String, username: String, password: String, correctpassword: String, completion: @escaping (Result<SignupResponse, AuthenticationError>) -> Void) {
            // Ensure password matches confirm password
            guard password == correctpassword else {
                completion(.failure(.custom(errorMessage: "Passwords do not match.")))
                return
            }
            guard let url = URL(string: "https://everreadapp.onrender.com/api/auth/register") else {
                completion(.failure(.custom(errorMessage: "URL is not correct")))
                return
            }

            let body = SignupRequestBody(email: email, username: username, password: password, correctpassword: correctpassword)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONEncoder().encode(body)
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data, error == nil else {
                    completion(.failure(.custom(errorMessage: "No data")))
                    return
                }
                // Log raw response string
                if let rawResponse = String(data: data, encoding: .utf8) {
                    print("Raw response from server:\n\(rawResponse)")
                }
                
                do {
                    let signupResponse = try JSONDecoder().decode(SignupResponse.self, from: data)
                    print("Signup successful for user: \(signupResponse.username)")
                    // Return the successful response with user details
                    completion(.success(signupResponse))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(.custom(errorMessage: "Failed to decode server response: \(error.localizedDescription)")))
                }
            }.resume()
        }
    }
