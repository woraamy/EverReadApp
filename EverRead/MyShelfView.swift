
import SwiftUI

enum ShelfTab{
    case Current
    case Want
    case Finish
}


struct MyShelfView: View{
    @State private var selectedTab: ShelfTab = .Current
    var body: some View {
        ZStack{
            Color.softWhitePink.ignoresSafeArea()
            VStack(alignment: .leading){
                Text("My Shelves").font(.title)
                
                HStack {
                    TabButton(label: "Reading", tab: ShelfTab.Current, selectedTab: $selectedTab)
                    TabButton(label: "Wish List", tab: ShelfTab.Want, selectedTab: $selectedTab)
                    TabButton(label: "Read", tab: ShelfTab.Finish, selectedTab: $selectedTab)
                }.frame(width:350 , height: 50)
                    .background(Color.redPink)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.bottom, 10)
                
                Group {
                    switch selectedTab {
                    case .Current:
                        ForEach(1..<5){ i in
                            ActivityCard(name:"John Reader", action: "Started reading The hobbit", recentDay: 2).padding(1)
                        }
                    case .Want:
                        ForEach(1..<5){ i in
                            ReviewCard(name:"Jane Reader", book: "Babel", rating: 5, detail:"What a good book to read! i cried when reading this")
                        }
                    case .Finish:
                        ReadGoalCard()
                        SummaryCard()
                    }
                }           
            }.padding(30).frame(maxWidth:.infinity,maxHeight: .infinity, alignment: .topLeading)
            
        }
    }
}

#Preview {
    MyShelfView()
}
