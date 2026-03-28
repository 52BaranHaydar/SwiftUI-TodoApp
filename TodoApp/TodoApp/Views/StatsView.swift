//
//  StatsView.swift
//  TodoApp
//
//  Created by Baran on 28.03.2026.
//
import SwiftUI

struct StatsView: View {
    let todos: [TodoItem]
    @EnvironmentObject var languageManager: LanguageManager
    
    var completed: Int { todos.filter { $0.isCompleted }.count }
    var pending: Int { todos.filter { !$0.isCompleted }.count }
    var total: Int { todos.count }
    var completionRate: Double {
        total == 0 ? 0 : Double(completed) / Double(total)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("stats".localized(using: languageManager))
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                StatCard(title: "total".localized(using: languageManager), value: "\(total)", icon: "list.bullet", color: .blue)
                StatCard(title: "completed".localized(using: languageManager), value: "\(completed)", icon: "checkmark.circle", color: .green)
                StatCard(title: "pending".localized(using: languageManager), value: "\(pending)", icon: "clock", color: .orange)
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("completion_rate".localized(using: languageManager))
                        .font(.subheadline)
                    Spacer()
                    Text("%\(Int(completionRate * 100))")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(colors: [.green, .blue], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * completionRate, height: 12)
                            .animation(.easeInOut, value: completionRate)
                    }
                }
                .frame(height: 12)
            }
            .padding()
            .background(Color.gray.opacity(0.08))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.08))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.2), lineWidth: 1))
    }
}

#Preview {
    StatsView(todos: [])
        .environmentObject(LanguageManager())
}
