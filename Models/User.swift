//
//  User.swift
//  SocialFeed
//
//  Created by MacMy on 15.11.2025.
//

/// Модель пользователя
struct User: Codable {
    let id: Int
    let name: String
    let username: String
    let email: String
}
