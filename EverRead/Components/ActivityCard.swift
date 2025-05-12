import SwiftUI

import SwiftUI

struct ActivityCard: View {
    var name: String
    var action: String
    var recentDay: Int
    var book_name: String
    var profile: String
    var userId: String
    @AppStorage("authToken") var token = ""
    var actionText: String {
        switch action {
        case "write a review":
            return "Wrote a review for \(book_name)"
        case "add want to read":
            return "Added \(book_name) to want to read"
        case "add currently reading":
            return "Started reading \(book_name)"
        case "add finished":
            return "Finished reading \(book_name)"
        default:
            return "Did something"
        }
    }
    
    var body: some View {
        Group {
            if userId != "" {
                NavigationLink(destination: OtherProfileView(UserId: userId)) {
                    content
                }
                .buttonStyle(PlainButtonStyle()) // to keep the visual style
            } else {
                content
            }
        }
    }
    
    private var content: some View {
        VStack(alignment: .leading) {
            HStack {
                if profile.isEmpty {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 80))
                } else {
                    AsyncImage(url: URL(string: profile)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 70, height: 70)
                                .clipShape(Circle())
                        case .failure:
                            Image(systemName: "person.crop.circle.badge.exclam")
                                .font(.system(size: 80))
                                .foregroundColor(.red)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    Text(name).font(.title3)
                    Text(actionText).font(.subheadline).foregroundColor(.pinkGray)
                    Text("\(recentDay) days ago").font(.subheadline).foregroundColor(.pinkGray)
                }
            }
        }
        .padding()
        .frame(width: 350, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.darkPinkBrown, lineWidth: 1)
        )
    }
}
#Preview {
    ActivityCard(name: "John Reader", action: "write a review", recentDay: 2, book_name: "", profile: "",userId: "681c94d1ab5d1ac0b5051db2")
}
