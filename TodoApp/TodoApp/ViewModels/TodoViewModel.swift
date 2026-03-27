//
//  TodoViewModel.swift
//  TodoApp
//
//  Created by Baran on 28.03.2026.
//

import Foundation
import Combine
import SwiftUI

class TodoViewModel: ObservableObject{
    @Published var todos: [TodoItem] = []
    
    private let saveKey = "todos"
    
    init(){
        load()
    }
    
    func add(title: String){
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        todos.append(TodoItem(title: title))
        save()
    }
    
    
    func toggle(_ item: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == item.id}){
            todos[index].isCompleted.toggle()
            save()
        }
    }
    
    func delete(at offsets: IndexSet) {
        todos.remove(atOffsets: offsets)
        save()
    }
    
    private func save(){
        if let encoded = try? JSONEncoder().encode(todos){
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func load(){
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([TodoItem].self, from: data){
            todos = decoded
        }
    }
    
}
