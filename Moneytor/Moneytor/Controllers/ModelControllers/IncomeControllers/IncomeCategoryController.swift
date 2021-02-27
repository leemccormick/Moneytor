//
//  IncomeCategoryController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/24/21.
//

import CoreData

class IncomeCategoryController {
    static let shared = IncomeCategoryController()
    var incomeCategories: [IncomeCategory] = [
        IncomeCategory(name: "other", emoji: "💵"),
    IncomeCategory(name: "salary", emoji: "💳"),
    IncomeCategory(name: "saving", emoji: "💰"),
    IncomeCategory(name: "checking", emoji: "🏧")
   
]
    
    var categorySections: [[Income]] = []
    
    private lazy var fetchRequest: NSFetchRequest<IncomeCategory> = {
        let request = NSFetchRequest<IncomeCategory>(entityName: "IncomeCategory")
        request.predicate = NSPredicate(value: true)
        return request
    }()
    
    // MARK: - CRUD Methods
    // CREATE
    func createIncomeCategories(name: String, emoji: String) {
        let newIncomeCategory = IncomeCategory(name: name, emoji: emoji)
        
        for incomeCategory in incomeCategories {
            if newIncomeCategory == incomeCategory {
                print("==================\n :: NEW INCOME CATEGORY IS DUPICATED. \(newIncomeCategory.name)\n=======================")

            } else {
                
            incomeCategories.append(newIncomeCategory)
            }
        }
        
        
       
        
        
        
       // incomeCategories.removeDuplicates()
        CoreDataStack.shared.saveContext()
    }
    
    // READ
    func fetchAllIncomeCategories(){
        let fetchAllIncomeCatagories = (try? CoreDataStack.shared.context.fetch(fetchRequest)) ?? []
        
       // let newIncategories =
        incomeCategories = fetchAllIncomeCatagories
        
      
    }
    
    func generateIncomeCategories() {
        fetchAllIncomeCategories()
        let newIncomeCategory = incomeCategories.removeDuplicates()
        //var newIncomeCategory: [IncomeCategory] = []
        for incomeCategory in newIncomeCategory {
            let incomesCategory = incomeCategory.incomes
            let newIncomesCategory = incomesCategory?.compactMap {$0 as? Income} ?? []
            //newIncomeCategory.removeDuplicates()
            categorySections.append(newIncomesCategory)
        }
    }
    
    
    
    // UPDATE
    
    // DELETE
    
}
