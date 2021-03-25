//
//  Income+Convenience.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/23/21.
//

import CoreData

extension Income {
    
    @discardableResult convenience init(name: String, amount: Double, date: Date, note: String, id: String, incomeCategory: IncomeCategory,  context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.init(context: context)
        self.name = name
        self.amount = NSDecimalNumber(value: amount)
        self.date = date
        self.note = note
        self.id = id
        self.incomeCategory = incomeCategory
       
    }
}

extension Income: SearchableRecordDelegate {
    
    var incomeNameString: String {
        name ?? ""
    }
    
    var incomeAmountString: String {
        AmountFormatter.currencyInString(num: amount as? Double ?? 0.0)
    }
    
    var incomeAmountStringToUpdate: String {
        AmountFormatter.numberIn2DecimalPlaces.string(from: NSNumber(value: amount?.doubleValue ?? 0)) ?? ""
    }
    
    var incomeDateText: String {
        self.date?.dateToString(format: .monthDayYear) ?? Date().dateToString(format: .monthDayYear)
    }
    
    var incomeNoteString: String {
        note ?? ""
    }
    
}

