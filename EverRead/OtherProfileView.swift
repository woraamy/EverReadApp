import SwiftUI

struct OtherProfileView: View {
    @State private var selectedTab: Tab = .Activity
    @EnvironmentObject var session: UserSession
    @StateObject private var dataManager = DataManager()
    @AppStorage("authToken") var token = ""
    @State private var reviews: [ReviewsItem] = []
    var body: some View {
        if !session.isLoggedIn{
            SignInView()
        } else {
            let user = dataManager.user
           
            ZStack {
                Color.softWhitePink
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    OtherProfileHeader()
                    ScrollView{
                        VStack{
                            ProfileCard(
                                name: user?.username ?? "username",
                                bookRead: String(user?.book_read ?? 0),
                                reading: String(user?.reading ?? 0),
                                review: String(user?.review ?? 0),
                                follower: "432",
                                following: "87")
                        }
                        // tab
                        HStack {
                            Text("Review")
                            
                        }.frame(width:350, height:40 )
                            .background(Color.redPink)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.bottom, 10)
                       
                        ScrollView{
                                if reviews.isEmpty {
                                       Text("No reviews available.")
                                           .foregroundColor(.gray)
                                           .padding()
                                   } else {
                                       ForEach(reviews, id: \.id) { review in
                                           ReviewCard(
                                               name: user?.username ?? "username",
                                               book: review.bookName,
                                               rating: review.rating,
                                               detail: review.description,
                                               book_id: review.apiId
                                           )
                                       }
                                   }
                        }
                    }
                }
            }.foregroundColor(.darkPinkBrown)
                .onAppear{
                    dataManager.fetchUser()
                    fetchReviews(token: token)
                }
            
        }
    }
            func fetchReviews(token: String) {
                ReviewAPIService().GetUserReview(token: token) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let fetchedReviews):
                            self.reviews = fetchedReviews
                        case .failure(let error):
                            print("Error fetching reviews: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    


#Preview {
    OtherProfileView().environmentObject(UserSession())
}
