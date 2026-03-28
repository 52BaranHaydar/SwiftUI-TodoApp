//
//  Category.swift
//  TodoApp
//
//  Created by Baran on 28.03.2026.
//

import Foundation

enum Category : String, CaseIterable, Codable {
    case personal = "Kişisel"
    case work = "İş"
    case shopping = "Alışveriş"
    case health = "Sağlık"
    case other = "Diğer"
    
    var icon : String{
        switch self{
        case .personal: return "person.fill"
        case .work: return "briefcase.fill"
        case .shopping: return "cart.fill"
        case .health: return "heart.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: String{
        switch self{
        case .personal: return "blue"
        case .work: return "orange"
        case .shopping: return "green"
        case .health: return "red"
        case .other: return "purple"
        }
    }
    
}
