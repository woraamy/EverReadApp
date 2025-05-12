import SwiftUI

struct ProfileCard: View {
    var name:String
    var bookRead:String
    var reading:String
    var review:String
    var follower:String
    var following:String
    var profile: String
    var body: some View {
        VStack(alignment: .leading){
            // Profile
            HStack{
                if profile == ""{
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 80))
                }else {
                    AsyncImage(url: URL(string: profile)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height:80)
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
                    Text(name).font(.title2)
                    Text("@\(name)").font(.subheadline).padding(.bottom, 5)
                        .foregroundColor(.pinkGray)
                    HStack{
                        Text("\(follower) Followers")
                        Text("\(following) Following")
                    }
                }
            }.padding(.bottom,5)
            //bio
            Text("Book lover | Fantasy & Sci-Fi enthusiast | Always looking for new recommendations" ).font(.subheadline).padding(.bottom, 5)
            //info card
            HStack{
                VStack{
                    Image(systemName: "book")
                        .font(.system(size: 20)).padding(.bottom,1)
                    Text("Book Read").font(.subheadline)
                    Text(bookRead).fontWeight(.bold)
                }.padding()
                    .background(Color.redPink)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/))
                VStack{
                    Image(systemName: "calendar")
                        .font(.system(size: 20)).padding(.bottom,1)
                    Text("  Reading  ").font(.subheadline)
                    Text(reading).fontWeight(.bold)
                }.padding()
                    .background(Color.redPink)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/))
                VStack{
                    Image(systemName: "star.bubble")
                        .font(.system(size: 20)).padding(.bottom,1)
                    Text("   Review   ").font(.subheadline)
                    Text(review).fontWeight(.bold)
                }.padding()
                    .background(Color.redPink)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/))            }
        }.padding()
    }
}

#Preview {
    ProfileCard(name:"Jane Reader",bookRead: "42", reading: "3",review: "10", follower: "432", following: "87", profile: "")
}
