import SwiftUI


struct EditProfileView: View {
    @State private var selectedTab: Tab = .Activity
    @EnvironmentObject var session: UserSession
    @StateObject private var dataManager = DataManager()
    @AppStorage("authToken") var token = ""
    @State private var bioText = ""
    @State private var nameText = ""
    var body: some View {
        let user = dataManager.user
        ZStack {
            Color.softWhitePink
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView{
                    VStack{
                        Text("Edit profile")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.bottom, 5)
                        Divider()
                        ProfileCard(
                            name: user?.username ?? "username",
                            bookRead: String(user?.book_read ?? 0),
                            reading: String(user?.reading ?? 0),
                            review: String(user?.review ?? 0),
                            follower: "432",
                            following: "87")
                        Divider()                    }
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Change your name").font(.headline)
                            .padding(.top)
                        TextField("Your new name", text: $nameText)
                            .padding(6)
                            .background(Color.white)
                            .border(Color.gray.opacity(0.3))
                            .cornerRadius(5)
                        Text("Change your Bio")
                            .font(.headline)
                            .padding(.top)
                        
                        TextEditor(text: $bioText)
                            .frame(height: 100)
                            .border(Color.gray.opacity(0.3))
                            .cornerRadius(5)
                            .overlay(
                                bioText.isEmpty ? Text("Sharing your biography")
                                    .foregroundColor(.gray.opacity(0.6))
                                    .padding(8)
                                    .allowsHitTesting(false) : nil
                                , alignment: .topLeading
                            )
                        
                        Button("Submit Changes") {
                            print("Submit Review tapped. Rating: ")
                        }.buttonStyle(PrimaryButtonStyle())
                            .disabled(nameText.isEmpty && bioText.isEmpty)
                    }.frame(width: 350)
                }
            }.foregroundColor(.darkPinkBrown)
                .onAppear{
                    dataManager.fetchUser()
                }
        }
    }
    
}


#Preview {
    EditProfileView().environmentObject(UserSession())
}
