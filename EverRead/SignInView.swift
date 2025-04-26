import SwiftUI

struct SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    var body: some View {
        NavigationStack{
            ZStack{
                Color.softWhitePink
                    .ignoresSafeArea()
                ScrollView{
                    VStack(alignment: .leading){
                        Text("Sign In").font(.title)
                            .bold()
                            .padding(.top, 50)
                            .padding(.bottom, 100)
                        GoogleSignInButton()
                            .padding(5)
                        HStack {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(height: 1)
                            
                            Text("Or")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 8)
                            
                            Rectangle()
                                .fill(Color.gray)
                                .frame(height: 1)
                        }.padding(.top, 20).padding(.bottom, 10)
                        
                        VStack(alignment: .leading){
                            Text("Email Address")
                            TextField("Email", text: $email)
                                .padding(6)
                                .background(Color.darkPink)
                                .padding(3)
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                            
                        }.frame(alignment: .leading).padding(2)
                        
                        VStack(alignment: .leading){
                            Text("Password")
                            SecureField("*************", text: $password)
                                .padding(6)
                                .background(Color.darkPink)
                                .padding(3)
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                        }.frame(alignment: .leading)
                        
                        Button(action: {
                            print("Log In")
                        }){
                            HStack{
                                Text("Login")
                            }.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/).padding().background(Color.sakuraPink)
                            .clipShape(RoundedRectangle(cornerRadius: 16))                    }.padding(.top, 20)
                        Spacer(minLength: 50)
                        
                        HStack{
                            Text("Are you a new member?").font(.title3)
                            NavigationLink(
                                destination: SignUpView()
                               ){
                                Text("SINGUP").font(.title3)
                            }
                        }.frame(width: 325, alignment:  .center)
                    }.frame( width: 325, alignment: .leading)
                }
                
            }
        }
    }
}
#Preview {
    SignInView()
}
