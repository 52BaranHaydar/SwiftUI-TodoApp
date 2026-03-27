//
//  TodoAppApp.swift
//  TodoApp
//
//  Created by Baran on 28.03.2026.
//

import SwiftUI
import CoreData

@main
struct TodoAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
