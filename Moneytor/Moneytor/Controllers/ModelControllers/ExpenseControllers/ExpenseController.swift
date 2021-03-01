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
    func createExpenseWith(name: String, amount:Double, category: ExpenseCategory, date: Date) {
        //let newCategory = category
        
        guard let categoryID = category.id else {return}
        let newExpense = Expense(name: name, amount: amount, date: date, id: categoryID, expenseCategory: category)
        expenses.append(newExpense)
        category.expenses?.adding(newExpense)
        CoreDataStack.shared.saveContext()
    }
    
    // READ
    func fetchAllExpenses() {
        let fetchIncomes = (try? CoreDataStack.shared.context.fetch(fetchRequest)) ?? []
        expenses = fetchIncomes
    }
    
    // UPDATE
    func updateWith(_ expense: Expense, name: String, amount: Double, category: ExpenseCategory, date: Date){
        expense.name = name
        expense.amount = NSDecimalNumber(value: amount)
        expense.expenseCategory = category
        expense.date = date
        CoreDataStack.shared.saveContext()
    }
    
    // DELETE
    func deleteExpense(_ expense: Expense){
        
        //guard let expenseCategory = expense.expenseCategory else {return}
        expense.expenseCategory?.removeFromExpenses(expense)
        CoreDataStack.shared.context.delete(expense)
       
        CoreDataStack.shared.saveContext()
        fetchAllExpenses()
    }
}
