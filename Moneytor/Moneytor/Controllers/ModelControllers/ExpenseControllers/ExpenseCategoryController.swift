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
        let newExpenseCategory = ExpenseCategory(name: name, emoji: emoji, expenses: nil)
fetchAllExpenseCategory()
        
        if expenseCategories.count > 0 {
         for x in expenseCategories {
            if x.name == newExpenseCategory.name {
                 print("Unable to create new ExpenseCategory because The Category' Name Already exist !! ")
                 //mainManagedObjectContext.deleteObject(x)
               }
             }
          }
        expenseCategories.append(newExpenseCategory)
        CoreDataStack.shared.saveContext()
    }
    
    // READ
    func fetchAllExpenseCategory(){
        
        let fetchAllExpenseCatagories = (try? CoreDataStack.shared.context.fetch(fetchRequest)) ?? []
//         if fetchAllExpenseCatagories.count > 0 {
//            expenseCategories = fetchAllExpenseCatagories
//          for x in fetchAllExpenseCatagories {
//            for j in expenseCategories {
//                if x.name == j.name {
//                  print("already exist")
//                CoreDataStack.shared.context.delete(x)
//                }
//              }
//          }
//        }
        
        expenseCategories = fetchAllExpenseCatagories.removeDuplicates()
        //expenseCategories.removeDuplicates()
        CoreDataStack.shared.saveContext()
        print(expenseCategories.count)
        print("==================\n :: expenseCategories.count \(expenseCategories.count)\n=======================")
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
           

//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Card")
//                var resultsArr:[Card] = []
//                do {
//                    resultsArr = try (mainManagedObjectContext!.fetch(fetchRequest) as! [Card])
//                } catch {
//                    let fetchError = error as NSError
//                    print(fetchError)
//                }
//
//         if resultsArr.count > 0 {
//          for x in resultsArr {
//            if x.id == id {
//                  print("already exist")
//                  mainManagedObjectContext.deleteObject(x)
//                }
//              }
//           }
//
        
        
//        func isExist(id: Int) -> Bool {
//            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ExpenseCategory")
//            fetchRequest.predicate = NSPredicate(format: "id = %d", argumentArray: name)
//
//            let res = try! theContext.fetch(fetchRequest)
//            return res.count > 0 ? true : false
//        }
//
//       }
}

