//
//  EverReadApp.swift
//  EverRead
//
//  Created by Worawalan Chatlatanagulchai on 15/4/2568 BE.
//

import SwiftUI

@main
struct EverReadApp: App {
    @StateObject private var session = UserSession()

    var body: some Scene {
        WindowGroup {
            if (session.isLoggedIn){
                MainTabView().environmentObject(UserSession())
            }else{
                SignInView().environmentObject(UserSession())            }
        }
    }
}

