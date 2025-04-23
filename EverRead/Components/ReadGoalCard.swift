import SwiftUI

struct ReadGoalCard: View {
    var yearGoalValue:Double = 0.29
    var monthGoalValue:Double = 0.5
    var body: some View {
        VStack(alignment: .leading){
            Text("Reading Goals")
                .font(.title3)
                .fontWeight(.bold)
            HStack{
                // Yearly Goal
                VStack(alignment: .leading){
                    HStack{
                        Image(systemName: "calendar")
                        Text("Yearly Goal")
                    }
                    Text("7").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).bold()
                    HStack{
                        Text("Of 24 books").font(.caption)
                        Spacer()
                        Text("29%").font(.subheadline).bold()
                    }
                    ZStack(alignment: .leading) {
                        Capsule()
                            .frame(height: 10)
                            .foregroundColor(.gray.opacity(0.2))
                                Capsule()
                                    .frame(width: CGFloat(yearGoalValue) * 150 , height: 10)
                                    .foregroundColor(.pink)
                            }
                }.padding().frame(width: 175,alignment: .leading).background(Color.redPink).clipShape(RoundedRectangle(cornerRadius: 10))
                //Monthly Goal
                VStack(alignment: .leading){
                    HStack{
                        Image(systemName: "book.circle")
                        Text("Monthly Goal")
                    }
                    Text("1").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).bold()
                    HStack{
                        Text("Of 2 books").font(.caption)
                        Spacer()
                        Text("50%").font(.subheadline).bold()
                    }
                    ZStack(alignment: .leading) {
                        Capsule()
                            .frame(height: 10)
                            .foregroundColor(.gray.opacity(0.2))
                                Capsule()
                                    .frame(width: CGFloat(monthGoalValue) * 150 , height: 10)
                                    .foregroundColor(.pink)
                            }
                }.padding().frame(width: 175,alignment: .leading).background(Color.redPink).clipShape(RoundedRectangle(cornerRadius: 10))
                                                                                                      }
        }
        
    }
}

#Preview {
    ReadGoalCard()
}
