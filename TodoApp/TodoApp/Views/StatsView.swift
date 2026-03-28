//
//  StatsView.swift
//  TodoApp
//
//  Created by Baran on 28.03.2026.
//

import SwiftUI

struct StatsView: View {
    let todos: [TodoItem]
    
    var completed: Int { todos.filter { $0.isCompleted }.count }
    var pending: Int { todos.filter { !$0.isCompleted }.count }
    var total: Int { todos.count }
    var completionRate: Double {
        total == 0 ? 0 : Double(completed) / Double(total)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("İstatistikler")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                StatCard(title: "Toplam", value: "\(total)", icon: "list.bullet", color: .blue)
                StatCard(title: "Tamamlanan", value: "\(completed)", icon: "checkmark.circle", color: .green)
                StatCard(title: "Bekleyen", value: "\(pending)", icon: "clock", color: .orange)
            }
            .padding(.horizontal)
            
            // Tamamlanma oranı
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Tamamlanma Oranı")
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
                            .fill(Color.green)
                            .frame(width: geo.size.width * completionRate, height: 12)
                            .animation(.easeInOut, value: completionRate)
                    }
                }
                .frame(height: 12)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
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
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    StatsView(todos: [])
}
