//
//  Income+Convenience.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/23/21.
//

import CoreData

extension Income {
    @discardableResult convenience init(name: String, amount: Double, date: Date, incomeCategory: IncomeCategory, context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.init(context: context)
        self.name = name
        self.amount = NSDecimalNumber(value: amount)
        self.date = date
        self.incomeCategory = incomeCategory
    }
}

extension Income {
    
    var incomeNameString: String {
        name ?? ""
    }
    
    var incomeAmountStringToUpdate: String {
         AmountFormatter.numberIn2DecimalPlaces.string(from: NSNumber(value: amount?.doubleValue ?? 0)) ?? ""
    }
    
//    var incomeCategoryString: IncomeCategory {
//          IncomeCategory(rawValue: category ?? "") ?? .other
//      }
    
    var incomeDateText: String {
        self.date?.dateToString(format: .monthDayTimestamp) ?? Date().dateToString(format: .monthDayTimestamp)
    }
    
   
    
    var incomeAmountString: String {
        let newFormatAmount = AmountFormatter.numberIn2DecimalPlaces.string(from: NSNumber(value: amount?.doubleValue ?? 0)) ?? ""
        return "$ \(newFormatAmount)"
    }
}
