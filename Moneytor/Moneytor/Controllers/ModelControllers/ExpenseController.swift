//
//  ExpenseController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/23/21.
//

import CoreData

class ExpenseController {
    // MARK: - Properties
    static let shared = ExpenseController()
    var expenses:[Expense] = []
    private lazy var fetchRequest: NSFetchRequest<Expense> = {
        let request = NSFetchRequest<Expense>(entityName: "Expense")
        request.predicate = NSPredicate(value: true)
        return request
    }()
    
    // MARK: - CRUD Methods
    // CREATE
    func createIncome(name: String, amount:Double, category: String, date: Date) {
        let newExpense = Expense(name: name, amount: amount, category: category, date: date)
        expenses.append(newExpense)
        CoreDataStack.shared.saveContext()
    }
    
    // READ
    func fetchAllExpenses() {
        let fetchIncomes = (try? CoreDataStack.shared.context.fetch(fetchRequest)) ?? []
        expenses = fetchIncomes
    }
    
    // UPDATE
    func updateExpense(expense: Expense, name: String, amount: Double, category: String, date: Date){
        expense.name = name
        expense.amount = NSDecimalNumber(value: amount)
        expense.category = category
        expense.date = date
        CoreDataStack.shared.saveContext()
    }
    
    // DELETE
    func deleteExpense(expense: Expense){
        CoreDataStack.shared.context.delete(expense)
        CoreDataStack.shared.saveContext()
    }
}
