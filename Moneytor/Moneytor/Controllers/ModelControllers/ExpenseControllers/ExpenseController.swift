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
    var expenses: [Expense] = []
    
    private lazy var fetchRequest: NSFetchRequest<Expense> = {
        let request = NSFetchRequest<Expense>(entityName: "Expense")
        request.predicate = NSPredicate(value: true)
        let dateSortDescriptor = NSSortDescriptor(key: #keyPath(Income.date), ascending: false)
        request.sortDescriptors = [dateSortDescriptor]
        return request
    }()
    
    // MARK: - CRUD Methods
    // CREATE
    func createExpenseWith(name: String, amount:Double, category: ExpenseCategory, date: Date) {
        
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
    
    func fetchExpensesFromTimePeriod(_ time: Date) -> [Expense]{
           var expenses: [Expense] = []
           let now = Date()
           let fetchRequest: NSFetchRequest<Expense> = NSFetchRequest <Expense>(entityName: "Expense")
           let datePredicate = NSPredicate(format: "date > %@ AND date < %@", time as NSDate, now as NSDate)
           fetchRequest.predicate = datePredicate
           fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
           do {
               let fetchExpenses = try(CoreDataStack.shared.context.fetch(fetchRequest))
               expenses.append(contentsOf: fetchExpenses)
           } catch {
               print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
           }
           return expenses
       }
       

    func fetchExpensesFromTimePeriodAndCategory(_ time: Date, categoryName: String) -> [Expense]{
        var expenses: [Expense] = []
        let now = Date()
        let fetchRequest: NSFetchRequest<Expense> = NSFetchRequest <Expense>(entityName: "Expense")
    
        let datePredicate = NSPredicate(format: "date > %@ AND date < %@", time as NSDate, now as NSDate)
        let categoryPredicate = NSPredicate(format: "expenseCategory.name == %@", categoryName)
        
        let finalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, categoryPredicate])
        fetchRequest.predicate = finalPredicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "expenseCategory.name", ascending: true)]
        do {
            let fetchIncomes = try(CoreDataStack.shared.context.fetch(fetchRequest))
            expenses.append(contentsOf: fetchIncomes)
        } catch {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
        return expenses
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
        expense.expenseCategory?.removeFromExpenses(expense)
        CoreDataStack.shared.context.delete(expense)
        CoreDataStack.shared.saveContext()
        fetchAllExpenses()
    }
}
