//
//  ThemeManager.swift
//  TodoApp
//
//  Created by Baran on 28.03.2026.
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
}
