//
//  Expense+Convenience.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/23/21.
//

import CoreData

extension Expense {
    @discardableResult convenience init(name: String, amount: Double, date: Date, note: String, id: String, expenseCategory: ExpenseCategory, image: Data, context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.init(context: context)
        self.name = name
        self.amount = NSDecimalNumber(value: amount)
        self.date = date
        self.note = note
        self.id = id
        self.expenseCategory = expenseCategory
        self.image = image
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
    
    var expenseDateText: String {
        self.date?.dateToString(format: .monthDayYear) ?? Date().dateToString(format: .monthDayYear)
    }
    
    var expenseNoteString: String {
        note ?? ""
    }
    
    var expenseAmountInDouble: Double {
        amount?.doubleValue ?? 0.0
    }
}
