//
//  SceneDelegateSocialNet.swift
//  SocialFeed
//
//  Created by MacMy on 16.11.2025.
//

import UIKit

class SceneDelegateSocialNet: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
      window?.rootViewController = UINavigationController(rootViewController: FeedViewController())
        window?.makeKeyAndVisible()
    }
}
