//
//  Category.swift
//  TodoApp
//
//  Created by Baran on 28.03.2026.
//

import Foundation
import SwiftUI

enum Category: String, CaseIterable, Codable {
    case personal = "personal"
    case work = "work"
    case shopping = "shopping"
    case health = "health"
    case other = "other"
    
    func title(using lm: LanguageManager) -> String {
        rawValue.localized(using: lm)
    }
    
    var icon: String {
        switch self {
        case .personal: return "person.fill"
        case .work:     return "briefcase.fill"
        case .shopping: return "cart.fill"
        case .health:   return "heart.fill"
        case .other:    return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .personal: return .blue
        case .work:     return .orange
        case .shopping: return .green
        case .health:   return .red
        case .other:    return .purple
        }
    }
}
