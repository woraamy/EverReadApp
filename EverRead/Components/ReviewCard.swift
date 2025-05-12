import SwiftUI

struct ReviewCard: View {
    var name: String
    var book: String
    var rating: Int
    var detail: String
    var book_id: String
    var userId: String
    @State private var showDialog: Bool = false
    
    var slicedDetail: String {
        if detail.count > 50 {
            let start = detail.index(detail.startIndex, offsetBy: 50)
            return String(detail[start...])
        } else {
            return ""
        }
    }
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
               // Image("bookImg")
                 //   .resizable().frame(width: 70, height: 100)
                VStack(alignment: .leading) {
                    HStack {
                        Text(name).font(.title3)
                        Spacer()
                        Text("Rating \(rating)")
                    }
                    Text("Reviewed \(book)")
                        .font(.subheadline)
                        .foregroundColor(.pinkGray)
                    Text(detail.prefix(50) + (detail.count > 50 ? "..." : ""))
                        .font(.body)
                        .padding(.top, 5)
                }
            }
        }
        .padding()
        .frame(width: 350, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.darkPinkBrown, lineWidth: 1)
        )
        .contentShape(Rectangle()) // Ensures whole area is tappable
        .onTapGesture {
            showDialog = true
        }
        .sheet(isPresented: $showDialog) {
            ReviewDialog(book: book, detail: detail, rating: rating, name: name, userId:userId)
        }
    }
}
struct ReviewDialog: View {
    @Environment(\.dismiss) var dismiss
    var book: String
    var detail: String
    var rating: Int
    var name: String
    var userId:String

    var body: some View {
        NavigationView{
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.pink.opacity(0.3), Color.white]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ).ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 15) {
                    Text(book)
                        .font(.title)
                        .bold()
                    if userId != "" {
                        NavigationLink(destination: OtherProfileView(UserId: userId)) {
                            Text("By: \(name)")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .underline()
                        }
                    } else {
                        Text("By: \(name)")
                            .font(.subheadline)
                    }
                    Text("Rating: \(rating)/5")
                        .font(.headline)
                    Divider()
                    Text(detail)
                        .font(.body)
                    Spacer()
                    Button("Close") {
                        dismiss()
                    }
                    .padding(.top)
                }
                .padding()
            }
        }
    }
}

#Preview {
    ReviewCard(name:"Jane Reader", book: "Babel", rating: 5, detail:"What a good book to read! i cried when reading this", book_id: "", userId: "")
}
