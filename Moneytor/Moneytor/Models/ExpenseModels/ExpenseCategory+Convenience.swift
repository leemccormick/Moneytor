//
//  ExpenseCategory.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/24/21.
//


import CoreData

extension ExpenseCategory {
    
    @discardableResult convenience init(name: String = "other", emoji: String = "💸", id: String = UUID().uuidString, expenses: NSSet?, context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.init(context: context)
        self.name = name
        self.emoji = emoji
        self.id = id
        self.expenses = expenses
    }
}


extension ExpenseCategory {
    var nameString: String {
        name ?? "other"
    }
    
    var emojoString: String {
        emoji ?? "💸"
    }
    
    var idString: String {
        id ?? ""
    }
    
//    func removeExpenseDuplicates() -> [ExpenseCategory] {
//        var results = [ExpenseCategory]()
//        
//        for value in results {
//            if results.contains(value.name) == false {
//                results.append(value as! ExpenseCategory)
//            }
//        }
//        return results
//    }
}
