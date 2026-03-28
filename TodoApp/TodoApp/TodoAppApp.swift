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
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                ContentView()
                    .environmentObject(themeManager)
                    .environmentObject(languageManager)
                    .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
            } else {
                OnboardingView()
                    .environmentObject(themeManager)
                    .environmentObject(languageManager)
                    .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
            }
        }
    }
}
