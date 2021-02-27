//
//  ExpenseCategory.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/24/21.
//


import CoreData

extension ExpenseCategory {
    
    @discardableResult convenience init(name: String = "other", emoji: String = "💸", id: String = UUID().uuidString, context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.init(context: context)
        self.name = name
        self.emoji = emoji
        self.id = id
    }
}
