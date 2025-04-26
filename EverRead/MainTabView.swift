//
//  MainTabView.swift
//  EverRead
//
//  Created by Worawalan Chatlatanagulchai on 23/4/2568 BE.
//

import Foundation

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            
            HomePage()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0) 
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(1)
            
            MyShelfView()
                .tabItem {
                    Label("Shelves", systemImage: "books.vertical")
                }
                .tag(2)

            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "newspaper")                }
                .tag(3)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(4)
        }
        .accentColor(.darkPinkBrown)
    }
}

struct ShelvesView: View {
    var body: some View {
        ZStack {
            Color.redPink.ignoresSafeArea()
            Text("Shelves Page")
                .foregroundColor(.darkPinkBrown)
                .navigationTitle("Shelves") // Optional
        }
    }
}

struct FeedView: View {
    var body: some View {
        ZStack {
            Color.redPink.ignoresSafeArea()
            Text("Feed Page")
                .foregroundColor(.darkPinkBrown)
                .navigationTitle("Feed") // Optional
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
