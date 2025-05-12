import SwiftUI

struct OtherProfileView: View {
    var UserId:String
    @State private var selectedTab: Tab = .Activity
    @EnvironmentObject var session: UserSession
    @StateObject private var dataManager = DataManager()
    @AppStorage("authToken") var token = ""
    @State private var reviews: [ReviewsItem] = []
    var body: some View {
        if !session.isLoggedIn{
            SignInView()
        } else {
            let user = dataManager.otherUser
           
            ZStack {
                Color.softWhitePink
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    OtherProfileHeader(userId:UserId)
                    ScrollView{
                        VStack{
                            ProfileCard(
                                name: user?.username ?? "username",
                                bookRead: String(user?.book_read ?? 0),
                                reading: String(user?.reading ?? 0),
                                review: String(user?.review ?? 0),
                                follower: String(user?.follower ?? 0),
                                following: String(user?.following ?? 0),
                                profile: user?.profile_img ?? "",
                                bio: user?.bio ?? ""
                            ).frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
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
                                               book_id: review.apiId,
                                               userId: ""
                                           )
                                       }
                                   }
                        }
                    }
                }
            }.foregroundColor(.darkPinkBrown)
                .onAppear{
                    dataManager.fetchUserById(user_id: UserId)
                    fetchReviews(user_id:UserId, token: token)
                }
        }
    }
    func fetchReviews(user_id:String, token: String) {
        ReviewAPIService().GetReviewByUserId(user_id:user_id,token: token) { result in
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
    OtherProfileView(UserId: "681c94d1ab5d1ac0b5051db2").environmentObject(UserSession())
}
