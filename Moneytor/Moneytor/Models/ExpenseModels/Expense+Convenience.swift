//
//  Expense+Convenience.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/23/21.
//

import CoreData

extension Expense {
    @discardableResult convenience init(name: String, amount: Double, date: Date, expensesCategory: ExpenseCategory, context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.init(context: context)
        self.name = name
        self.amount = NSDecimalNumber(value: amount)
        self.date = date
        self.expenseCategory = expensesCategory
       
    }
}
extension Expense: SearchableRecordDelegate {
    
    var expenseNameString: String {
        name ?? ""
    }
    
    var expenseAmountString: String {
        AmountFormatter.currencyInString(num: amount as? Double ?? 0.0)
    }
    
    var expenseAmountToUpdate: String {
 AmountFormatter.numberIn2DecimalPlaces.string(from: NSNumber(value: amount?.doubleValue ?? 0)) ?? ""
    }
    
    
//    var expenseCategoryString: IncomeCategory {
//          IncomeCategory(rawValue: category ?? "") ?? .other
//      }
//    
    var expenseDateText: String {
        self.date?.dateToString(format: .monthDayTimestamp) ?? Date().dateToString(format: .monthDayTimestamp)
    }
    
//
//
//    var incomeAmountTextInDecimal: String {
//        Formatter.numberFormatterIn2DecimalPlaces.string(from: NSNumber(value: amount?.doubleValue ?? 0)) ?? ""    }
}
