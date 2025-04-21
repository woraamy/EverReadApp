import SwiftUI

struct ActivityCard: View {
    var name: String
    var action: String
    var recentDay: Int
    
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 60))
                VStack(alignment: .leading) {
                    Text(name).font(.title3)
                    Text(action).font(.subheadline).foregroundColor(.pinkGray)
                    Text("\(recentDay) days ago").font(.subheadline).foregroundColor(.pinkGray)            }
            }
        }
        .padding().frame(width: 350, alignment: .leading)
            .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.darkPinkBrown, lineWidth: 1)
            )
        }
}

#Preview {
    ActivityCard(name:"John Reader", action: "Started reading The hobbit", recentDay: 2)
}
