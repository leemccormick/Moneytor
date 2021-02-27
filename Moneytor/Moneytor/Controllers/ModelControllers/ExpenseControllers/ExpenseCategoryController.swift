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
        ExpenseCategory(name: "other", emoji: "💸"),
        ExpenseCategory(name: "food", emoji: "🍔"),
        ExpenseCategory(name: "utility", emoji: "📞"),
        ExpenseCategory(name: "health", emoji: "💪"),
        ExpenseCategory(name: "grocery", emoji: "🛒"),
        ExpenseCategory(name: "shopping", emoji: "🛍"),
        ExpenseCategory(name: "entertainment", emoji: "🎬"),
        ExpenseCategory(name: "transportation", emoji: "🚘")
]
    private lazy var fetchRequest: NSFetchRequest<ExpenseCategory> = {
        let request = NSFetchRequest<ExpenseCategory>(entityName: "ExpenseCategory")
        request.predicate = NSPredicate(value: true)
        return request
    }()
    
    // MARK: - CRUD Methods
    // CREATE
    func createExpenseCategories(name: String = "other", emoji: String = "💵"){
        let newExpenseCategory = ExpenseCategory(name: name, emoji: emoji)
        expenseCategories.append(newExpenseCategory)
        CoreDataStack.shared.saveContext()
    }
    
    // READ
    func fetchAllIncomeCategories(){
        let fetchAllIncomeCatagories = (try? CoreDataStack.shared.context.fetch(fetchRequest)) ?? []
        expenseCategories = fetchAllIncomeCatagories
    }
    
    // UPDATE
    
    // DELETE
    
}

