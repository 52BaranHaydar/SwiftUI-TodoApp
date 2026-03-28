//
//  SettingsView.swift
//  TodoApp
//
//  Created by Baran on 28.03.2026.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ayarlar")
                .font(.headline)
                .padding(.horizontal)
            
            HStack {
                Image(systemName: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                    .foregroundColor(themeManager.isDarkMode ? .yellow : .orange)
                    .font(.title3)
                
                Text("Karanlık Mod")
                    .font(.subheadline)
                
                Spacer()
                
                Toggle("", isOn: $themeManager.isDarkMode)
                    .labelsHidden()
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager())
}
