//
//  CalendarView.swift
//  TodoApp
//
//  Created by Baran on 28.03.2026.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var languageManager: LanguageManager
    let todos: [TodoItem]
    
    @State private var selectedDate = Date()
    
    var calendar = Calendar.current
    
    var todosForSelectedDate: [TodoItem] {
        todos.filter {
            if let reminder = $0.reminderDate {
                return calendar.isDate(reminder, inSameDayAs: selectedDate)
            }
            return calendar.isDate($0.createdAt, inSameDayAs: selectedDate)
        }
    }
    
    var datesWithTodos: Set<String> {
        var dates = Set<String>()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        for todo in todos {
            dates.insert(formatter.string(from: todo.createdAt))
            if let reminder = todo.reminderDate {
                dates.insert(formatter.string(from: reminder))
            }
        }
        return dates
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // Takvim
                DatePicker(
                    "Tarih Seç",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                .background(Color.gray.opacity(0.08))
                .cornerRadius(16)
                .padding()
                
                // Seçili güne ait görevler
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(selectedDate.formatted(date: .long, time: .omitted))
                            .font(.headline)
                        Spacer()
                        Text("\(todosForSelectedDate.count) görev")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    if todosForSelectedDate.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "calendar.badge.checkmark")
                                .font(.system(size: 48))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("Bu gün için görev yok")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 32)
                    } else {
                        List {
                            ForEach(todosForSelectedDate) { item in
                                HStack(spacing: 12) {
                                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(item.isCompleted ? .green : .gray)
                                        .font(.title3)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.title)
                                            .strikethrough(item.isCompleted)
                                            .fontWeight(.medium)
                                        
                                        HStack(spacing: 6) {
                                            Label(item.category.title(using: languageManager), systemImage: item.category.icon)
                                                .font(.caption)
                                                .foregroundColor(item.category.color)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(item.category.color.opacity(0.1))
                                                .cornerRadius(6)
                                            
                                            Label(item.priority.title(using: languageManager), systemImage: item.priority.icon)
                                                .font(.caption)
                                                .foregroundColor(item.priority.color)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(item.priority.color.opacity(0.1))
                                                .cornerRadius(6)
                                        }
                                    }
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .padding(.vertical, 4)
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Takvim")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CalendarView(todos: [])
        .environmentObject(LanguageManager())
}
