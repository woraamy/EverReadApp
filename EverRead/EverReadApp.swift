//
//  EverReadApp.swift
//  EverRead
//
//  Created by Worawalan Chatlatanagulchai on 15/4/2568 BE.
//

import SwiftUI

@main
struct EverReadApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("userToken") private var userToken: String = ""

    var body: some Scene {
        WindowGroup {
            if (isLoggedIn){
                MainTabView()
            }else{
                SignInView()
            }
        }
    }
}

