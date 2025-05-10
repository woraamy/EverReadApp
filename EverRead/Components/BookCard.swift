import SwiftUI

struct BookCard: View {
    var status: String
    var img: String
    var name: String
    var author: String
    var progress: Int

    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: secureImageUrl(img)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width:100,height: 140)
                        .background(Color.gray.opacity(0.1))
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    
                    Image(systemName: "book.closed")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                        .frame(width:100,height: 140)
                        .background(Color.gray.opacity(0.1))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width:100,height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )

            Text(name).padding(.leading, 1).bold().lineLimit(2).frame(height: 40, alignment: .top)
            Text(author).padding(.leading, 1).font(.subheadline).lineLimit(1)
            
            if status == "current" {
                ZStack(alignment: .leading) {
                    Capsule()
                        .frame(height: 10)
                        .foregroundColor(.gray.opacity(0.2))
                    Capsule()
                        .frame(width: CGFloat(progress) * 1.0, height: 10) 
                        .foregroundColor(.pink)
                }
                .frame(width: 100)
            }
        }
        .frame(width: 100)
    }
}
#Preview {
    BookCard(status: "current", img: "BookImg", name: "Babel", author: "R. F. Kuang", progress: 50)
}
