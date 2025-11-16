//
//  NetworkManager.swift
//  SocialFeed
//
//  Created by MacMy on 15.11.2025.
//

import Foundation
import Alamofire

/// Менеджер для работы с сетевыми запросами
class NetworkManager {
  
  static let shared = NetworkManager()
  
  private init() {}
  
  /// Загрузка постов с API
  func fetchPosts2(completion: @escaping (Result<[Post], Error>) -> Void) {
    AF.request(APIEndpoints.posts, method: .get)
      .validate()
      .responseDecodable(of: [Post].self) { response in
        switch response.result {
        case .success(let posts):
          completion(.success(posts))
        case .failure(let error):
          completion(.failure(error))
        }
      }
  }
  
  func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
    print("🌐 Начинаем запрос к: \(APIEndpoints.posts)")
    
    AF.request(APIEndpoints.posts, method: .get)
      .validate()
      .responseDecodable(of: [Post].self) { response in
        
        // 1. Логируем URL и метод
        //print("📍 URL: \(response.request?.url?.absoluteString ?? "нет URL")")
        //print("📍 Method: \(response.request?.httpMethod ?? "нет метода")")
        
        // 2. Логируем заголовки запроса
        //print("📤 Request Headers:")
        response.request?.allHTTPHeaderFields?.forEach { key, value in
          //print("  \(key): \(value)")
        }
        
        // 3. Логируем статус код
        if let statusCode = response.response?.statusCode {
          //print("📊 Status Code: \(statusCode)")
        }
        
        // 4. Логируем заголовки ответа
        //print("📥 Response Headers:")
        response.response?.allHeaderFields.forEach { key, value in
          //print("  \(key): \(value)")
        }
        
        // 5. Логируем сырые данные
        if let data = response.data {
          //print("📦 Response Data Size: \(data.count) bytes")
          
          // Показываем первые 500 символов JSON
          if let jsonString = String(data: data, encoding: .utf8) {
            let preview = String(jsonString.prefix(500))
            //print("📄 Response JSON (preview):")
            //print(preview)
            if jsonString.count > 500 {
              //print("... (еще \(jsonString.count - 500) символов)")
            }
          }
        }
        
        // 6. Логируем результат парсинга
        switch response.result {
        case .success(let posts):
          //print("✅ Успешно загружено постов: \(posts.count)")
          //print("📝 Первый пост: \(posts.first?.title ?? "нет")")
          completion(.success(posts))
          
        case .failure(let error):
          print("❌ Ошибка запроса:")
          //print("  Тип: \(type(of: error))")
          //print("  Описание: \(error.localizedDescription)")
          
          // Детальная информация об ошибке
          if let afError = error as? AFError {
            switch afError {
            case .responseValidationFailed(let reason):
              print("  Validation failed: \(reason)")
            case .responseSerializationFailed(let reason):
              print("  Serialization failed: \(reason)")
            default:
              print("  AF Error: \(afError)")
            }
          }
          
          completion(.failure(error))
        }
        
        // 7. Логируем время выполнения
        if let metrics = response.metrics {
          //print("⏱️ Request duration: \(metrics.taskInterval.duration)s")
        }
      }
  }
}
