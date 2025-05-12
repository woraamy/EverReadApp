import SwiftUI

struct SignUpView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showDialog:Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    private let authenticationService = AuthenticationService()
    @EnvironmentObject var session: UserSession
    @State private var navigateToLogin: Bool = false
    var body: some View {
        NavigationStack {
            ZStack {
                Color.softWhitePink
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Sign Up")
                            .font(.title)
                            .bold()
                            .padding(.top, 20)
                            .padding(.bottom, 30)
                        
                        
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        
                        Group {
                            VStack(alignment: .leading) {
                                Text("Username")
                                TextField("Username", text: $username)
                                    .padding(6)
                                    .background(Color.darkPink)
                                    .padding(3)
                                    .clipShape(RoundedRectangle(cornerRadius: 25))
                            }
                            .padding(2)
                            
                            
                            VStack(alignment: .leading) {
                                Text("Email Address")
                                TextField("Email", text: $email)
                                    .padding(6)
                                    .background(Color.darkPink)
                                    .padding(3)
                                    .clipShape(RoundedRectangle(cornerRadius: 25))
                            }
                            .padding(2)
                            
                            VStack(alignment: .leading) {
                                Text("Password")
                                SecureField("*************", text: $password)
                                    .padding(6)
                                    .background(Color.darkPink)
                                    .padding(3)
                                    .clipShape(RoundedRectangle(cornerRadius: 25))
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Confirm Password")
                                SecureField("*************", text: $confirmPassword)
                                    .padding(6)
                                    .background(Color.darkPink)
                                    .padding(3)
                                    .clipShape(RoundedRectangle(cornerRadius: 25))
                            }
                        }
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
                            sigupUser()
                        }) {
                            Text("Sign Up")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.sakuraPink)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.top, 20)
                        
                        Spacer(minLength: 50)
                        
                        HStack {
                            Text("Already have an account?")
                                .font(.title3)
                            
                            NavigationLink(destination: SignInView()) {
                                Text("SIGN IN")
                                    .font(.title3)
                            }
                        }
                        .frame(width: 325, alignment: .center)
                    }
                    .frame(width: 325, alignment: .leading)
                }
            }
        }.sheet(isPresented: $showDialog) {
            DialogView()
        }
    }
    private func sigupUser() {
        errorMessage = nil
        isLoading = true
        
        authenticationService.signup(email: email, username: username, password: password, correctpassword: confirmPassword) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    print("Signup successful!")
                    self.showDialog = true
                    
                case .failure(let error):
                    switch error {
                    case .invalidCredentials:
                        self.errorMessage = "Invalid credentials"
                    case .custom(let message):
                        self.errorMessage = message
                    }
                }
            }
        }
    }
}
struct DialogView: View {
    var body: some View {
        NavigationStack{
            
            ZStack(){
                LinearGradient(
                    gradient: Gradient(colors: [Color.pink.opacity(0.3), Color.white]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ).ignoresSafeArea()
                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                {
                    VStack{
                        Image(systemName: "person.crop.circle.fill").font(.system(size: 80)).foregroundColor(.darkPinkBrown)
                        Text("Sign Up Successful!")
                            .font(.title)
                            .bold()
                        HStack {
                            Text("Go to" )
                                .font(.title3)
                            
                            NavigationLink(destination: SignInView()) {
                                Text("SIGN IN")
                                    .font(.title3)
                            }
                        }
                    }.padding()
                   
                }
                .padding()
                
            }
        }
    }
}

#Preview {
    SignUpView()
}
