//
//  Priority.swift
//  TodoApp
//
//  Created by Baran on 28.03.2026.
//

import Foundation

enum Priority: Int, CaseIterable, Codable, Comparable {
    case low = 0
    case medium = 1
    case high = 2
    
    var title :String {
        switch self{
        case .low : return "Düşük"
        case .medium: return "Orta"
        case .high: return "Yüksek"
        }
    }
    
    var icon: String {
        switch self{
        case .low : return "green"
        case .medium: return "orange"
        case .high: return "red"
        }
    }
    static func < (lhs: Priority, rhs: Priority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    
}
