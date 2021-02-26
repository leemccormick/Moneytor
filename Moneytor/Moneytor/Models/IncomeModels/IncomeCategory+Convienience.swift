//
//  IncomeCategory+Convienience.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/24/21.
//

import CoreData

extension IncomeCategory: SearchableRecordDelegate {
    @discardableResult convenience init(name: String = "other", emoji: String = "💵", context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.init(context: context)
        self.name = name
        self.emoji = emoji
    }
}
