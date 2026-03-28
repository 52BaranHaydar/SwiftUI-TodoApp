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
    @StateObject private var languageManager = LanguageManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .environmentObject(languageManager)
                .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        }
    }
}
