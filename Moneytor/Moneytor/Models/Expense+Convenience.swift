//
//  Expense+Convenience.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/23/21.
//

import CoreData

extension Expense {
    @discardableResult convenience init(name: String, amount: Double, category: String, date: Date, context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.init(context: context)
        self.name = name
        self.amount = NSDecimalNumber(value: amount)
        self.category = category
        self.date = date
    }
}
extension Expense {
    
    var expenseNameString: String {
        name ?? ""
    }
    
    var expenseAmountString: String {
        let amountString = NSString(format: "%@", self.amount ?? 00.00)
           let newAmountString = "$ \(amountString as String)"
           return newAmountString
    }
    
    var expenseCategoryString: IncomeCategory {
          IncomeCategory(rawValue: category ?? "") ?? .other
      }
    
    var expenseDateText: String {
        self.date?.dateToString(format: .monthDayTimestamp) ?? Date().dateToString(format: .monthDayTimestamp)
    }
    
//
//
//    var incomeAmountTextInDecimal: String {
//        Formatter.numberFormatterIn2DecimalPlaces.string(from: NSNumber(value: amount?.doubleValue ?? 0)) ?? ""    }
}
