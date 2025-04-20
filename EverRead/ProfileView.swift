import SwiftUI

enum Tab {
    case Activity
    case Review
    case Stats
}

struct ProfileView: View {
    @State private var selectedTab: Tab = .Activity
    var body: some View {
        ZStack {
            Color.softWhitePink
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TabHeader(title: "Profile") {
                    print("Signing out...")
                }
                ScrollView{
                    VStack{
                        ProfileCard()
                    }
                    // tab
                    HStack {
                        ProfileTabButton(label: "Activity", tab: .Activity, selectedTab: $selectedTab)
                        ProfileTabButton(label: "Review", tab: .Review, selectedTab: $selectedTab)
                        ProfileTabButton(label: "Stats", tab: .Stats, selectedTab: $selectedTab)
                    }.frame(width:350, height:40 )
                        .background(Color.redPink)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.bottom, 10)
                    
                    Group {
                        switch selectedTab {
                        case .Activity:
                            ForEach(1..<5){ i in
                                ActivityCard(name:"John Reader", action: "Started reading The hobbit", recentDay: 2).padding(1)
                            }
                        case .Review:
                            ForEach(1..<5){ i in
                                ReviewCard(name:"Jane Reader", book: "Babel", rating: 5, detail:"What a good book to read! i cried when reading this")
                            }
                        case .Stats:
                            ReadGoalCard()
                            SummaryCard()
                        }
                    }
                }
            }
        }.foregroundColor(.darkPinkBrown)
    }
}

#Preview {
    ProfileView()
}
