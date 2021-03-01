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
    
//    var expenseArray: [Expense] {
//        let set = expenses as? Set<Expense> ?? []
//        return set
//    }
    
    
//   func insert(at id: String?, into category: String?) -> Self? {
//        //unwrap managed object context and id
//       // let  context = CoreDataStack.shared.context
//
//        guard let context = context, let id = id else {return nil}
//        
//        guard let context = context, let id = id else { return nil }
//        let categoryName = category ?? self.entityName //the table name in CoreData
//        let request: NSFetchRequest<Self> = NSFetchRequest(entityName: categoryName)
//        request.predicate = NSPredicate(format: "id == %@", id) //filter only results matching 'id'
//        if let result = try? context.fetch(request), let object = result.first
//        {
//            //return the existing object
//            return object
//        }
//        else if let entity = NSEntityDescription.entity(forEntityName: tableName, in: context)
//        {
//            //initialize and return a new object
//            return self.init(entity: entity, insertInto: context)
//        }
//        return nil
//    }
    
    
    
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
