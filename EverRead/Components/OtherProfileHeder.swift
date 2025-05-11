//
//  OtherProfileHeder.swift
//  EverRead
//
//  Created by user269706 on 5/12/25.
//

import SwiftUI

struct OtherProfileHeader: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isFollowing = false
    var title: String = "Profile"
    var body: some View {
        HStack {
            HStack {
                Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.blue)
                            }
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.leading, 4)
            }

            Spacer()

            Button(action: {
                isFollowing.toggle()
                // Add your backend follow/unfollow logic here
            }) {
                Text(isFollowing ? "Unfollow" : "Follow")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(isFollowing ? Color.gray : Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 2, y: 2)
    }
}

#Preview {
    OtherProfileHeader()
}
