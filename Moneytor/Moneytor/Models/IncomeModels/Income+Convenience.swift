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

extension Income: SearchableRecordDelegate {
 
    var incomeNameString: String {
        name ?? ""
    }
    
    var incomeAmountStringToUpdate: String {
         AmountFormatter.numberIn2DecimalPlaces.string(from: NSNumber(value: amount?.doubleValue ?? 0)) ?? ""
    }
    
    var incomeDateText: String {
        self.date?.dateToString(format: .monthDayTimestamp) ?? Date().dateToString(format: .monthDayTimestamp)
    }
    
    var incomeAmountString: String {
        AmountFormatter.currencyInString(num: amount as? Double ?? 0.0)
    }
}

