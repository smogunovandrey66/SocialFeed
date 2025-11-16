//
//  AppDelegate.swift
//  SocialFeed
//
//  Created by MacMy on 15.11.2025.
//

import Foundation
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    return true
  }
  
  /// При необходимости можно подгружать нужную сцену
  /*func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
      return UISceneConfiguration(name: "Social net", sessionRole: connectingSceneSession.role)
  }*/
  
  // MARK: - Lifecycle
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Сохраняем данные при уходе в фон
    CoreDataManager.shared.saveContext()
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Сохраняем данные перед закрытием
    CoreDataManager.shared.saveContext()
  }
}
