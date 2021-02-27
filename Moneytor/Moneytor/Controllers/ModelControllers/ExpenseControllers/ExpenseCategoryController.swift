//
//  ExpenseCategory.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/24/21.
//

import CoreData

class ExpenseCategoryController {
    static let shared = ExpenseCategoryController()
    var expenseCategories: [ExpenseCategory] = [
    ExpenseCategory(name: "other", emoji: "💸",expenses: nil),
                ExpenseCategory(name: "food", emoji: "🍔",expenses: nil),
                ExpenseCategory(name: "utility", emoji: "📞",expenses: nil),
                ExpenseCategory(name: "health", emoji: "💪",expenses: nil),
                ExpenseCategory(name: "grocery", emoji: "🛒",expenses: nil),
                ExpenseCategory(name: "shopping", emoji: "🛍",expenses: nil),
                ExpenseCategory(name: "entertainment", emoji: "🎬",expenses: nil),
                ExpenseCategory(name: "transportation", emoji: "🚘",expenses: nil)
    ]

    private lazy var fetchRequest: NSFetchRequest<ExpenseCategory> = {
        let request = NSFetchRequest<ExpenseCategory>(entityName: "ExpenseCategory")
        request.predicate = NSPredicate(value: true)
        return request
    }()
    
    // MARK: - CRUD Methods
    // CREATE
    func createExpenseCategories(name: String, emoji: String){
        let expenseCategory = ExpenseCategory(name: name, emoji: emoji, expenses: nil)
        
        let newExpenseCategory = insertExpenseCategoryWith(at: expenseCategory.name)
        guard let category = newExpenseCategory else {return}
        expenseCategories.append(category)
               
               CoreDataStack.shared.saveContext()
           }
           

    // READ
    func fetchAllExpenseCategory(){
        
        let fetchAllExpenseCatagories = (try? CoreDataStack.shared.context.fetch(fetchRequest)) ?? []

        var newfetch: [ExpenseCategory] = []
        
        for expense in fetchAllExpenseCatagories {
            let newInsertCategory = insertExpenseCategoryWith(at: expense.name)
            
            guard let newInsert = newInsertCategory else {return}
            
            newfetch.append(newInsert)
          //  CoreDataStack.shared.saveContext()
        }
        
        
        expenseCategories = newfetch
        
  CoreDataStack.shared.saveContext()
        print(expenseCategories.count)
        print("==================\n :: expenseCategories.countn \(expenseCategories.count)\n=======================")
    }
    
    // READ
    
    func calculateTotalExpenseFromEachCatagory() {
   print("==================\n :: calculateTotalExpenseFromEachCatagory In EXpensesCategoryController\\n=======================")
//       
       fetchAllExpenseCategory()
           for category in expenseCategories {
            
            
            
            
               let expenseArray = category.expenses?.allObjects as? [Expense] ?? []
               var sum = 0.0
               for expense in expenseArray {
                   sum += expense.amount as! Double
               }
            print("-------------------\n \(String(describing: category.name)): total ::: \(sum) count :::\(String(describing: category.expenses?.count))")
            
           }
        
    }
    
    func insertExpenseCategoryWith(at name: String?) -> ExpenseCategory? {
      
        //unwrap managed object context and id
        let  context = CoreDataStack.shared.context

        //guard let context = context, let id,
        
        guard let id = name else { return nil }
        let categoryName = "ExpenseCategory" //the table name in CoreData
        let request: NSFetchRequest<ExpenseCategory> = NSFetchRequest(entityName: categoryName)
        
        
        request.predicate = NSPredicate(format: "id == %@", id) //filter only results matching 'id'
        
        
        if let result = try? context.fetch(request), let object = result.first
        {
            //return the existing object
            return object
        }
        else if let entity = NSEntityDescription.entity(forEntityName: categoryName, in: context)
        {
            //initialize and return a new object
            return ExpenseCategory.init(entity: entity, insertInto: context)
                
//                self.init(entity: entity, insertInto: context)
        }
        return nil
    }
}

