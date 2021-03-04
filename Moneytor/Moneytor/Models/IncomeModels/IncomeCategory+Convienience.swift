//
//  IncomeCategory+Convienience.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/24/21.
//

import CoreData

extension IncomeCategory: SearchableRecordDelegate {
    
    @discardableResult convenience init(name: String = "other", emoji: String = "💵", incomes: NSSet?, id: String = UUID().uuidString, context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.init(context: context)
        self.name = name
        self.emoji = emoji
        self.id = id
        self.incomes = incomes
    }
}

extension IncomeCategory {
    var nameString: String {
        name ?? "other"
    }
    
    var emojiString: String {
        emoji ?? "💸"
    }
    
    var idString: String {
        id ?? ""
    }
}
