//
//  TodoAppApp.swift
//  TodoApp
//
//  Created by Baran on 28.03.2026.
//

import SwiftUI

@main
struct TodoAppApp: App {
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        }
    }
}
