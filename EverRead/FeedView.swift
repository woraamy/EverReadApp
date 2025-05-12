//
//  FeedView.swift
//  EverRead
//
//  Created by user269706 on 5/12/25.
//

import SwiftUI

struct FeedView: View {
    var body: some View {
        NavigationStack{
            ZStack{
                Color.softWhitePink
                    .ignoresSafeArea()
                // MARK: - Header
                VStack(spacing: 0){
                    HStack {
                        HStack(spacing: 5) {
                            Image("logo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 60)
                            Text("Feed")
                                .font(.system(size: 32))
                                .fontWeight(.semibold)
                        }
                        Spacer()
                        NavigationLink(destination: ProfileView()) {
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                                .foregroundColor(.darkPinkBrown)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.5).blur(radius: 10))
                    
                    ScrollView{
                        
                    }
                }
            }
        }
    }
}

#Preview {
    FeedView()
}
