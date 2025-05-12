//
//  FeedView.swift
//  EverRead
//
//  Created by user269706 on 5/12/25.
//

import SwiftUI
enum FeedTab {
    case Review
    case Following
   }


struct FeedView: View {
    @State private var selectedTab:FeedTab = .Review
    @State private var reviews: [FeedReviewsItem] = []
    @State private var histories: [FeedHistoryItem] = []
    @AppStorage("authToken") var token = ""
    var body: some View {
        NavigationStack{
            ZStack{
                Color.softWhitePink
                    .ignoresSafeArea()
                // MARK: - Header
                VStack(spacing: 0){
                    HStack {
                        HStack(spacing: 5) {
                            Image("logo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 60)
                            Text("Feed")
                                .font(.system(size: 32))
                                .fontWeight(.semibold)
                        }
                        Spacer()
                        NavigationLink(destination: ProfileView()) {
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                                .foregroundColor(.darkPinkBrown)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.5).blur(radius: 10))
                    HStack {
                        TabButton(label: "Review", tab: .Review, selectedTab: $selectedTab)
                        TabButton(label: "Following", tab: .Following, selectedTab: $selectedTab)
                    }.frame(width:350, height:40 )
                        .background(Color.redPink)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.bottom, 10)
                    ScrollView{
                        switch selectedTab {
                        case .Review:
                            if reviews.isEmpty {
                                Text("No reviews available.")
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                ForEach(reviews, id: \.id) { review in
                                    ReviewCard(
                                        name: review.username,
                                        book: review.bookName,
                                        rating: review.rating,
                                        detail: review.description,
                                        book_id: review.apiId
                                    ).padding()
                                }
                            }
                        case .Following:
                            if histories.isEmpty {
                                Text("No activity")
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                ForEach(histories, id: \.id) { i in
                                    ActivityCard(
                                        name: i.username,
                                        action: i.action,
                                        recentDay: i.daysAgo,
                                        book_name: "",
                                        profile: i.profile 
                                    ).padding(1)
                                }
                            }
                        }
                        
                    }
                }
            }.onAppear {
                fetchFeedReview(token:token)
                fetchFeedHistory(token: token)
            }
        }
    }
    func fetchFeedReview(token:String) {
        FeedAPIService().GetFeedReview(token: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedFeed):
                    self.reviews = fetchedFeed
                case .failure(let error):
                    print("Error fetching feed reviews: \(error.localizedDescription)")
                }
            }
        }
    }
    func fetchFeedHistory(token:String) {
        FeedAPIService().GetFeedHistory(token: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedFeed):
                    self.histories = fetchedFeed
                case .failure(let error):
                    print("Error fetching feed reviews: \(error.localizedDescription)")
                }
            }
        }
    }}

#Preview {
    FeedView()
}
