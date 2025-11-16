//
//  APIEndpoints.swift
//  SocialFeed
//
//  Created by MacMy on 15.11.2025.
//

/// API эндпоинты
enum APIEndpoints {
    private static let baseURL = "https://jsonplaceholder.typicode.com"
    
    static let posts = "\(baseURL)/posts"
    static func user(id: Int) -> String {
        return "\(baseURL)/users/\(id)"
    }
}
