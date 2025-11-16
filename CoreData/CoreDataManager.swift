//
//  CoreDataManager.swift
//  SocialFeed
//
//  Created by MacMy on 15.11.2025.
//

// CoreData/CoreDataManager.swift

import CoreData
import UIKit

class CoreDataManager {
  
  static let shared = CoreDataManager()
  
  // MARK: - Core Data Stack
  
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "SocialFeed")
    
    container.loadPersistentStores { description, error in
      if let error = error {
        print("❌ ОШИБКА загрузки CoreData: \(error)")
        fatalError("Unable to load persistent stores: \(error)")
      }
      //            print("   Путь: \(description.url?.path ?? "нет пути")")
      
      // Проверяем, что Entity существует
      let entities = container.managedObjectModel.entities.map { $0.name ?? "unknown" }
    }
    
    return container
  }()
  
  var context: NSManagedObjectContext {
    return persistentContainer.viewContext
  }
  
  // MARK: - Core Data Saving
  
  func saveContext() {
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        let nsError = error as NSError
        print("❌ Ошибка сохранения: \(nsError), \(nsError.userInfo)")
      }
    }
  }
  
  // MARK: - CRUD Operations
  
  func savePosts(_ posts: [Post]) {
    
    // Проверяем, что Entity существует
    guard let entity = NSEntityDescription.entity(forEntityName: "PostEntity", in: context) else {
      print("❌ ОШИБКА: Entity 'PostEntity' не найдена!")
      print("   Доступные entities:")
      persistentContainer.managedObjectModel.entities.forEach { entity in
        print("   - \(entity.name ?? "без имени")")
      }
      return
    }
    
    // Удаляем старые посты
    deleteAllPosts()
    
    // Сохраняем новые
    for post in posts {
      let postEntity = NSManagedObject(entity: entity, insertInto: context)
      postEntity.setValue(Int32(post.id), forKey: "id")
      postEntity.setValue(Int32(post.userId), forKey: "userId")
      postEntity.setValue(post.title, forKey: "title")
      postEntity.setValue(post.body, forKey: "body")
      postEntity.setValue("https://picsum.photos/seed/\(post.userId)/100/100", forKey: "avatarURL")
    }
    
    saveContext()
  }
  
  func fetchPosts() -> [PostEntity] {
    
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PostEntity")
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
    
    do {
      let results = try context.fetch(fetchRequest)
      
      // Преобразуем в PostEntity (если Codegen = Class Definition)
      return results as? [PostEntity] ?? []
    } catch {
      print("❌ Ошибка загрузки из CoreData: \(error)")
      return []
    }
  }
  
  private func deleteAllPosts() {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PostEntity")
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    
    do {
      try context.execute(deleteRequest)
      try context.save()
    } catch {
      print("❌ Ошибка удаления: \(error)")
    }
  }
}
