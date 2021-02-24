//
//  ExpenseCategoryModel.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/23/21.
//

import Foundation

enum ExpenseCategory: String, CaseIterable {
    case food
    case utility
    case health
    case grocery
    case shopping
    case entertainment
    case transportation
    case other
    
    var systemNameIcon: String {
        switch self {
        case .food: return "🍔"
        case .utility: return "📞"
        case .health: return "💪"
        case .grocery: return "🛒"
        case .shopping: return "🛍"
        case .entertainment: return "🎬"
        case .transportation: return "🚘"
        case .other: return "💸"
        }
    }
    
    var systemNameForPicker: String {
        switch self{
        case .food: return "🍔 Food"
        case .utility: return "📞 Utility"
        case .health: return "💪 Health"
        case .grocery: return "🛒 Grocery"
        case .shopping: return "🛍 Shopping"
        case .entertainment: return "🎬 Entertainment"
        case .transportation: return "🚘 Transportation"
        case .other: return "💸 Other"
        }
    }
    
    var sytemNameInt: Int {
        switch self{
        case .food: return 0
        case .utility: return 1
        case .health: return 2
        case .grocery: return 3
        case .shopping: return 4
        case .entertainment: return 5
        case .transportation: return 6
        case .other: return 7
        }
    }
}

//struct ExpensesCategorySum: Identifiable, Equatable {
//    let sum: Double
//    let category: ExpenseCategory
//    var id: String { "\(category)\(sum)" }
//}
