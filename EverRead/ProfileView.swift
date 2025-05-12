import SwiftUI

enum Tab {
    case Activity
    case Review
    case Stats
   }

struct ProfileView: View {
    @State private var selectedTab: Tab = .Activity
    @EnvironmentObject var session: UserSession
    @StateObject private var dataManager = DataManager()
    @AppStorage("authToken") var token = ""
    @State private var reviews: [ReviewsItem] = []
    @State private var histories: [HistoryItem] = []
    var body: some View {
        if !session.isLoggedIn{
            SignInView()
        } else {
            let user = dataManager.user
            NavigationStack{
                ZStack {
                Color.softWhitePink
                    .ignoresSafeArea()
                    VStack(spacing: 0) {
                        TabHeader(title: "Profile") {
                            session.logout()
                        }
                        
                        ScrollView{
                            VStack{
                                ProfileCard(
                                    name: user?.username ?? "username",
                                    bookRead: String(user?.book_read ?? 0),
                                    reading: String(user?.reading ?? 0),
                                    review: String(user?.review ?? 0),
                                    follower: "432",
                                    following: "87",
                                    profile: user?.profile_img ?? "",
                                    bio: user?.bio ?? ""
                                ).frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                                
                            }
                            // tab
                            HStack {
                                TabButton(label: "Activity", tab: .Activity, selectedTab: $selectedTab)
                                TabButton(label: "Review", tab: .Review, selectedTab: $selectedTab)
                                TabButton(label: "Stats", tab: .Stats, selectedTab: $selectedTab)
                            }.frame(width:350, height:40 )
                                .background(Color.redPink)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding(.bottom, 10)
                            
                            Group {
                                switch selectedTab {
                                case .Activity:
                                    ForEach(histories){ i in
                                        ActivityCard(
                                            name:user?.username ?? "username",
                                            action: i.action,
                                            recentDay: i.daysAgo,
                                            book_name: "",
                                            profile: user?.profile_img ?? ""
                                        ).padding(1)
                                    }
                                case .Review:
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
                                case .Stats:
                                    ReadGoalCard(
                                        yearGoalValue: user?.yearly_book_read ?? 0,
                                        monthGoalValue: user?.monthly_book_read ?? 0,
                                        yearGoalTotal: user?.yearly_goal ?? 0,
                                        monthGoalTotal: user?.month_goal ?? 0,
                                        reload:{
                                            dataManager.fetchUser()
                                        })
                                    SummaryCard(
                                        totalBook: String(user?.book_read ?? 0),
                                        rating: String(user?.review ?? 0),
                                        page: String(user?.page_read ?? 0),
                                        streak: String(user?.reading_streak ?? 0))
                                }
                            }
                        }
                    }
                }
                }.foregroundColor(.darkPinkBrown)
                    .onAppear{
                        dataManager.fetchUser()
                        fetchReviews(token: token)
                        fetchHistory(token: token)
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
    func fetchHistory(token: String) {
        HistoryAPIService().GetHistory(token: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedhistory):
                    self.histories = fetchedhistory
                case .failure(let error):
                    print("Error fetching reviews: \(error.localizedDescription)")
                }
            }
        }
    }        }
    


#Preview {
    ProfileView().environmentObject(UserSession())
}
