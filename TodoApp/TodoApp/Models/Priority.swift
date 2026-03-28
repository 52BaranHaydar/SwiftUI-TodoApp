//
//  Priority.swift
//  TodoApp
//
//  Created by Baran on 28.03.2026.
//
import Foundation
import SwiftUI

enum Priority: Int, CaseIterable, Codable, Comparable {
    case low = 0
    case medium = 1
    case high = 2
    
    func title(using lm: LanguageManager) -> String {
        switch self {
        case .low:    return "low".localized(using: lm)
        case .medium: return "medium".localized(using: lm)
        case .high:   return "high".localized(using: lm)
        }
    }
    
    var icon: String {
        switch self {
        case .low:    return "arrow.down.circle.fill"
        case .medium: return "minus.circle.fill"
        case .high:   return "arrow.up.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .low:    return .green
        case .medium: return .orange
        case .high:   return .red
        }
    }
    
    static func < (lhs: Priority, rhs: Priority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
