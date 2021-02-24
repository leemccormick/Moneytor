//
//  IncomeCategoryModel.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/23/21.
//

import Foundation

enum IncomeCategory: String, CaseIterable {
    case salary
    case saving
    case checking
    case other
    
    var systemNameIcon: String {
        switch self{
        case .salary: return "💳"
        case .saving: return "💰"
        case .checking: return "🏧"
        case .other: return "💵"
        }
    }
    
    var systemNameForPicker: String
    {
        switch self{
        case .salary: return "💳  Salary / Paycheck"
        case .saving: return "💰  Saving Account"
        case .checking: return "🏧  Checking Account"
        case .other: return "💵  Other Income"
        }
    }
    
    var sytemNameInt: Int {
        switch self{
        case .salary: return 0
        case .saving: return 1
        case .checking: return 2
        case .other: return 3
        }
    }
}
