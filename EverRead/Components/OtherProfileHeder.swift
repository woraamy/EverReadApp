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
    @AppStorage("authToken") var token = ""
    @EnvironmentObject var session: UserSession
    var userId: String

    var body: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
            }
            Text("Profile")
                .font(.headline)
                .foregroundColor(.black)
                .padding(.leading, 4)
            Spacer()
            if userId != session.currentUser?.id {
                Button(action: {
                    FollowLogic(user_id: userId, token: token)
                    isFollowing.toggle()
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
        }
        .padding()
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 2, y: 2)
        .onAppear {
            fetchIsFollow(user_id: userId, token: token)
        }
    }

    func fetchIsFollow(user_id: String, token: String) {
        FollowAPIService().isFollowing(user_id: user_id, token: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.isFollowing = response.isFollowing
                case .failure(let error):
                    print("Error fetching is follow status: \(error.localizedDescription)")
                }
            }
        }
    }
    func FollowLogic(user_id:String,token:String){
        if self.isFollowing == true{
            FollowAPIService().unfollow(user_id: user_id, token: token) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        print("unfollow successfully")
                    case .failure(let error):
                        print("Error fetching is follow status: \(error.localizedDescription)")
                    }
                }
            }
        } else{
            FollowAPIService().follow(user_id: user_id, token: token) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        print("follow successfully")
                    case .failure(let error):
                        print("Error fetching is follow status: \(error.localizedDescription)")
                    }
                }
            }        }
    }
}



#Preview {
    OtherProfileHeader(userId: "681c94d1ab5d1ac0b5051db2").environmentObject(UserSession())}
