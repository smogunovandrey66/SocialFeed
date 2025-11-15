//
//  SocialFeedApp.swift
//  SocialFeed
//
//  Created by MacMy on 15.11.2025.
//

import SwiftUI

@main
struct SocialFeedApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
