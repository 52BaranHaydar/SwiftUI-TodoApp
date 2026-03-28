//
//  EditTodoView.swift
//  TodoApp
//
//  Created by Baran on 28.03.2026.
//

import SwiftUI

struct EditTodoView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    @ObservedObject var premiumManager = PremiumManager.shared
    
    @State var todo: TodoItem
    let onSave: (TodoItem) -> Void
    
    var priorityColor: Color {
        switch todo.priority {
        case .low:    return .green
        case .medium: return .orange
        case .high:   return .red
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Görev başlığı
                Section("Görev") {
                    TextField("Görev adı", text: $todo.title)
                }
                
                // Kategori
                Section("Kategori") {
                    ForEach(Category.allCases, id: \.self) { category in
                        HStack {
                            Image(systemName: category.icon)
                                .foregroundColor(category.color)
                                .frame(width: 28)
                            Text(category.title(using: languageManager))
                            Spacer()
                            if todo.category == category {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                todo.category = category
                            }
                        }
                    }
                }
                
                // Öncelik
                Section("Öncelik") {
                    ForEach(Priority.allCases, id: \.self) { priority in
                        HStack {
                            Image(systemName: priority.icon)
                                .foregroundColor(priority.color)
                                .frame(width: 28)
                            Text(priority.title(using: languageManager))
                            Spacer()
                            if todo.priority == priority {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                todo.priority = priority
                            }
                        }
                    }
                }
                
                // Hatırlatıcı
                if premiumManager.isPremium {
                    Section("Hatırlatıcı") {
                        Toggle("Hatırlatıcı Ekle", isOn: Binding(
                            get: { todo.reminderDate != nil },
                            set: { if !$0 { todo.reminderDate = nil } else { todo.reminderDate = Date() } }
                        ))
                        
                        if todo.reminderDate != nil {
                            DatePicker(
                                "Tarih & Saat",
                                selection: Binding(
                                    get: { todo.reminderDate ?? Date() },
                                    set: { todo.reminderDate = $0 }
                                ),
                                in: Date()...,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                        }
                    }
                }
                
                // Durum
                Section("Durum") {
                    Toggle("Tamamlandı", isOn: $todo.isCompleted)
                }
            }
            .navigationTitle("Görevi Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        onSave(todo)
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .disabled(todo.title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    EditTodoView(todo: TodoItem(title: "Test Görevi")) { _ in }
        .environmentObject(LanguageManager())
}
