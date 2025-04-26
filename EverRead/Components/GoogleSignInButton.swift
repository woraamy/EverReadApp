import SwiftUI

struct GoogleSignInButton: View {
    var body: some View {
        
        Button(action: {
            print("Sign in with google!")
        }){
            HStack{
                Image("GoogleIcon")
                    .resizable()
                    .frame(width: 30,height: 30)
                Text("Sign In With Google")
                
            }.padding()
                .frame(maxWidth: .infinity, maxHeight: 45)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/))
            .shadow(color: Color.black.opacity(0.5), radius: 2, y: 2)    }
    }
}

#Preview {
    GoogleSignInButton()
}
