import Foundation
import SwiftUI

class DataManager: ObservableObject {
    @Published var user: UserData?
    @AppStorage("authToken") var token: String = ""
    func fetchUser() {
        guard let url = URL(string: "https://everreadapp.onrender.com/api/fetchData/userData") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)        
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error:", error)
                return
            }

            guard let data = data else {
                print("No data")
                return
            }

            do {
                let decodedUser = try JSONDecoder().decode(UserData.self, from: data)
                DispatchQueue.main.async {
                    self.user = decodedUser
                    print(decodedUser)
                }
            } catch {
                print("Decoding error:", error)
            }
        }.resume()
    }
}
