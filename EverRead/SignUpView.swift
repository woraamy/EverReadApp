import SwiftUI

struct SignUpView: View {
    @State private var firstname: String = ""
    @State private var lastname: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

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
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)

                        Group {
                            VStack(alignment: .leading) {
                                Text("Firstname")
                                TextField("Firstname", text: $firstname)
                                    .padding(6)
                                    .background(Color.darkPink)
                                    .padding(3)
                                    .clipShape(RoundedRectangle(cornerRadius: 25))
                            }
                            .padding(2)

                            VStack(alignment: .leading) {
                                Text("Lastname")
                                TextField("Lastname", text: $lastname)
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

                        Button(action: {
                            print("Sign up")
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
        }
    }
}

#Preview {
    SignUpView()
}
