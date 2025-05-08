//
//  UserData.swift
//  EverRead
//
//  Created by user269706 on 5/9/25.
//

import Foundation
struct UserData: Codable, Identifiable {
    let id: String
    let username: String
    let email: String
    let yearly_goal: Int
    let month_goal: Int
    let created_at: String
    let book_read: Int
    let reading: Int
    let review: Int
    let yearly_book_read: Int
    let monthly_book_read: Int
    let page_read: Int
    let reading_streak: Int
}
