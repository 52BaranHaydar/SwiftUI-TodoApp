//
//  TodoViewModel.swift
//  TodoApp
//
//  Created by Baran on 28.03.2026.
//
import Foundation
import Combine
import SwiftUI

class TodoViewModel: ObservableObject {
    @Published var todos: [TodoItem] = []
    
    private let saveKey = "todos"
    
    init() {
        load()
        NotificationManager.shared.requestPermission()
    }
    
    func add(title: String, category: Category = .personal, priority: Priority = .medium) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        todos.append(TodoItem(title: title, category: category, priority: priority))
        save()
    }
    
    func toggle(_ item: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == item.id }) {
            todos[index].isCompleted.toggle()
            if todos[index].isCompleted {
                NotificationManager.shared.cancel(for: todos[index])
            }
            save()
        }
    }
    
    func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            NotificationManager.shared.cancel(for: todos[index])
        }
        todos.remove(atOffsets: offsets)
        save()
    }
    
    func setReminder(for item: TodoItem, at date: Date) {
        if let index = todos.firstIndex(where: { $0.id == item.id }) {
            todos[index].reminderDate = date
            NotificationManager.shared.schedule(for: todos[index], at: date)
            save()
        }
    }
    
    func sortByPriority() {
        todos.sort { $0.priority > $1.priority }
        save()
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([TodoItem].self, from: data) {
            todos = decoded
        }
    }
}
