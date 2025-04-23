import SwiftUI

struct BookCard: View{
    var status:String
    var img:String
    var name:String
    var author:String
    var progress:Int
    
    var body: some View {
        VStack(alignment: .leading){
            Image(img).resizable().frame(width:100,height: 140).clipShape(RoundedRectangle(cornerRadius: 16))
            Text(name).padding(.leading, 1).bold()
            Text(author).padding(.leading, 1).font(.subheadline)
            
            if status == "current"{
                ZStack(alignment: .leading) {
                    Capsule()
                        .frame(height: 10)
                        .foregroundColor(.gray.opacity(0.2))
                    Capsule()
                        .frame(width: CGFloat(progress) * 120 * 0.01, height: 10)
                        .foregroundColor(.pink)
                }
            }
        }.frame(width: 100)
    }
}

#Preview {
    BookCard(status: "current", img: "BookImg", name: "Babel", author: "R. F. Kuang", progress: 50)
}
