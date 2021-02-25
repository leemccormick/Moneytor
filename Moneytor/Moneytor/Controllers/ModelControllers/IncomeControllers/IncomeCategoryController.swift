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
    IncomeCategory(name: "salary", emoji: "💳"),
    IncomeCategory(name: "saving", emoji: "💰"),
    IncomeCategory(name: "checking", emoji: "🏧"),
    IncomeCategory(name: "other", emoji: "💵")
]
    private lazy var fetchRequest: NSFetchRequest<IncomeCategory> = {
        let request = NSFetchRequest<IncomeCategory>(entityName: "IncomeCategory")
        request.predicate = NSPredicate(value: true)
        return request
    }()
    
    // MARK: - CRUD Methods
    // CREATE
    func createIncomeCategories(name: String = "other", emoji: String = "💵"){
        let newIncomeCategory = IncomeCategory(name: name, emoji: emoji)
        incomeCategories.append(newIncomeCategory)
       // incomeCategories.removeDuplicates()
        CoreDataStack.shared.saveContext()
    }
    
    // READ
    func fetchAllIncomeCategories(){
        let fetchAllIncomeCatagories = (try? CoreDataStack.shared.context.fetch(fetchRequest)) ?? []
        incomeCategories = fetchAllIncomeCatagories
    }
    
    // UPDATE
    
    // DELETE
    
}
