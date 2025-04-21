import SwiftUI

struct TabHeader: View {
    var title: String
    var onSignOut: () -> Void

    var body: some View {
        HStack {
            HStack{
                Image(systemName: "arrow.left")
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.leading, 0.0)            }
            
            Spacer()
            Button(action: onSignOut) {
                Text("Sign Out")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 2, y: 2)
        }
}
#Preview{
    TabHeader(title:"Profile"){
        print("Signout")
    }
}
