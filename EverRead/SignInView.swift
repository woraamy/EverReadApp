import SwiftUI

struct SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @EnvironmentObject var session: UserSession
    private let authenticationService = AuthenticationService()
    
    var body: some View {
        if session.isLoggedIn {
            MainTabView()
        } else {
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
                        // Show loading spinner while requesting
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding(.top, 20)
                        }
                        
                        // Show error message if there is one
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding(.top, 10)
                        }
                        Button(action: {
                            loginUser()
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
    private func loginUser() {
        errorMessage = nil
        isLoading = true
        
        authenticationService.signin(email: email, password: password) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let (user, token)):
                    print("Logged in as: \(user.username)")
                    self.session.login(user: user, token: token) 
                case .failure(let error):
                    switch error {
                    case .invalidCredentials:
                        errorMessage = "Invalid credentials. Please check your email and password."
                    case .custom(let message):
                        errorMessage = message
                    }
                }
            }
        }
    }
}


#Preview {
    SignInView().environmentObject(UserSession())}
