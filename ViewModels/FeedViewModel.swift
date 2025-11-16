//
//  FeedViewModel.swift
//  SocialFeed
//
//  Created by MacMy on 15.11.2025.
//

import Foundation

class FeedViewModel {
  
  // MARK: - Properties
  
  private let networkManager = NetworkManager.shared
  private let coreDataManager = CoreDataManager.shared
  
  private(set) var posts: [PostDisplayData] = []
  
  var onPostsUpdated: (() -> Void)?
  var onError: ((String) -> Void)?
  var onLoadingStateChanged: ((Bool) -> Void)?
  
  // MARK: - Public Methods
  
  func loadPosts(forceRefresh: Bool = false) {
    onLoadingStateChanged?(true)
    
    if forceRefresh {
      fetchPostsFromNetwork()
    } else {
      loadPostsFromCache()
    }
  }
  
  // MARK: - Private Methods
  
  private func loadPostsFromCache() {
    
    let cachedPosts = coreDataManager.fetchPosts()
    
    if cachedPosts.isEmpty {
      fetchPostsFromNetwork()
    } else {
      
      //конвертируем PostEntity в PostDisplayData
      posts = cachedPosts.map { entity in
        PostDisplayData(
          id: Int(entity.id),
          userId: Int(entity.userId),
          title: entity.title ?? "Без заголовка",
          body: entity.body ?? "Без текста",
          avatarURL: entity.avatarURL ?? ""
        )
      }
      
      onLoadingStateChanged?(false)
      onPostsUpdated?()
    }
  }
  
  private func fetchPostsFromNetwork() {
    
    networkManager.fetchPosts { [weak self] result in
      guard let self = self else { return }
      
      self.onLoadingStateChanged?(false)
      
      switch result {
      case .success(let posts):
        print("✅ [ViewModel] Получено \(posts.count) постов из сети")
        
        // Сохраняем в CoreData
        self.coreDataManager.savePosts(posts)
        
        // Конвертируем для отображения
        self.posts = posts.map { post in
          PostDisplayData(
            id: post.id,
            userId: post.userId,
            title: post.title,
            body: post.body,
            avatarURL: "https://picsum.photos/seed/\(post.userId)/100/100"
          )
        }
        
        print("✅ [ViewModel] UI будет обновлён (\(self.posts.count) постов)")
        self.onPostsUpdated?()
        
      case .failure(let error):
        print("❌ [ViewModel] Ошибка: \(error.localizedDescription)")
        self.onError?("Ошибка загрузки: \(error.localizedDescription)")
        
        // Пробуем загрузить из кэша
        self.loadPostsFromCache()
      }
    }
  }
}

// MARK: - Display Model

struct PostDisplayData {
  let id: Int
  let userId: Int
  let title: String
  let body: String
  let avatarURL: String
}
