//
//  TodoItem.swift
//  TodoApp
//
//  Created by Baran on 28.03.2026.
//

import Foundation

struct TodoItem : Identifiable, Codable{
    var id: UUID = UUID()
    var title: String
    var isCompleted: Bool = false
    var createdAt :Date = Date()
    var category: Category = .personal
    var priority: Priority = .medium
}
