import SwiftUI

struct ReviewCard: View {
    var name: String
    var book: String
    var rating: Int
    var detail: String
    var slicedDetail: String {
            if detail.count > 50 {
                let start = detail.index(detail.startIndex, offsetBy: 50)
                return String(detail[start...])
            } else {
                return ""
            }
        }
        
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Image("BookImg")
                    .resizable().frame(width:70,height: 100)
                VStack(alignment: .leading) {
                    HStack{
                        Text(name).font(.title3)
                        Spacer()
                        Text("Rating \(rating)")
                    }
                    Text("Reviewed \(book)")
                        .font(.subheadline).foregroundColor(.pinkGray)
                    Text(detail.prefix(50) + (detail.count > 50 ? "..." : ""))
                                    .font(.body)
                                    .padding(.top, 5)
                }
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
    ReviewCard(name:"Jane Reader", book: "Babel", rating: 5, detail:"What a good book to read! i cried when reading this")
}
