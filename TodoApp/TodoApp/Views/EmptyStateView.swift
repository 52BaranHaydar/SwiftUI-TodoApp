//
//  EmptyStateView.swift
//  TodoApp
//
//  Created by Baran on 28.03.2026.
//

import SwiftUI

struct EmptyStateView: View {
    @EnvironmentObject var languageManager: LanguageManager
    let filterCategory: Category?
    
    var icon: String {
        if let category = filterCategory {
            return category.icon
        }
        return "checklist"
    }
    
    var color: Color {
        if let category = filterCategory {
            return category.color
        }
        return .blue
    }
    
    var title: String {
        if filterCategory != nil {
            return languageManager.language == "tr" ? "Bu kategoride görev yok" : "No tasks in this category"
        }
        return languageManager.language == "tr" ? "Henüz görev yok" : "No tasks yet"
    }
    
    var subtitle: String {
        languageManager.language == "tr"
            ? "Yeni bir görev eklemek için yukarıdaki alanı kullan"
            : "Use the field above to add a new task"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Circle()
                    .fill(color.opacity(0.08))
                    .frame(width: 90, height: 90)
                
                Image(systemName: icon)
                    .font(.system(size: 44))
                    .foregroundColor(color.opacity(0.6))
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EmptyStateView(filterCategory: nil)
        .environmentObject(LanguageManager())
}
