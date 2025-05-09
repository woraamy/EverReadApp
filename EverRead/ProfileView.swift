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
    var body: some View {
        if !session.isLoggedIn{
            SignInView()
        } else {
            let user = dataManager.user
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
                                following: "87")
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
                                ForEach(1..<5){ i in
                                    ActivityCard(name:user?.username ?? "username", action: "Started reading The hobbit", recentDay: 2).padding(1)
                                }
                            case .Review:
                                ForEach(1..<5){ i in
                                    ReviewCard(name:user?.username ?? "username", book: "Babel", rating: 5, detail:"What a good book to read! i cried when reading this")
                                }
                            case .Stats:
                                ReadGoalCard(
                                    yearGoalValue: user?.yearly_book_read ?? 0,
                                    monthGoalValue: user?.monthly_book_read ?? 0,
                                    yearGoalTotal: user?.yearly_goal ?? 0,
                                    monthGoalTotal: user?.month_goal ?? 0)
                                SummaryCard(
                                    totalBook: String(user?.book_read ?? 0),
                                    rating: String(user?.review ?? 0),
                                    page: String(user?.page_read ?? 0),
                                    streak: String(user?.reading_streak ?? 0))
                            }
                        }
                    }
                }
            }.foregroundColor(.darkPinkBrown).onAppear{dataManager.fetchUser()}
        }
    }
}

#Preview {
    ProfileView().environmentObject(UserSession())
}
