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
    let notificationScheduler = NotificationScheduler()
    
    private lazy var fetchRequest: NSFetchRequest<Expense> = {
        let request = NSFetchRequest<Expense>(entityName: "Expense")
        request.predicate = NSPredicate(value: true)
        let dateSortDescriptor = NSSortDescriptor(key: #keyPath(Income.date), ascending: false)
        request.sortDescriptors = [dateSortDescriptor]
        return request
    }()
    
    // MARK: - CRUD Methods
    // CREATE
    func createExpenseWith(name: String, amount:Double, category: ExpenseCategory, date: Date, note: String, image: Data?) {
        
        guard let categoryID = category.id else {return}
        if let image = image {
            let newExpense = Expense(name: name, amount: amount, date: date, note: note, id: categoryID, expenseCategory: category, image: image)
            expenses.append(newExpense)
            category.expenses?.adding(newExpense)
            CoreDataStack.shared.saveContext()
        } else {
            let newExpense = Expense(name: name, amount: amount, date: date, note: note, id: categoryID, expenseCategory: category, image: nil)
            expenses.append(newExpense)
            category.expenses?.adding(newExpense)
            CoreDataStack.shared.saveContext()
        }
    }
    
    func createExpenseAndNotificationWith(name: String, amount:Double, category: ExpenseCategory, date: Date, note: String, image: Data?) {
        guard let categoryID = category.id else {return}
        if let image = image {
            let newExpense = Expense(name: name, amount: amount, date: date, note: note, id: categoryID, expenseCategory: category, image: image)
            expenses.append(newExpense)
            category.expenses?.adding(newExpense)
            CoreDataStack.shared.saveContext()
            notificationScheduler.scheduleExpenseNotifications(expense: newExpense)
        } else {
            let newExpense = Expense(name: name, amount: amount, date: date, note: note, id: categoryID, expenseCategory: category, image: nil)
            expenses.append(newExpense)
            category.expenses?.adding(newExpense)
            CoreDataStack.shared.saveContext()
            notificationScheduler.scheduleExpenseNotifications(expense: newExpense)
        }
    }
    
    func createMonthlyExpensesAndNotificationsWith(repeatDuration: [Date], name: String, amount:Double, category: ExpenseCategory, date: Date, note: String, image: Data?) {
        guard let categoryID = category.id else {return}
        let repeatedDates = repeatDuration
        var monthlyNote = "*** This is monthly expense. ***"
        if note != "Take a note for your expense here or scan a receipt for expense's detail..." {
            monthlyNote = "*** This is monthly expense. *** \n\(note)"
        }
        if let image = image {
            for date in repeatedDates {
                let newExpense = Expense(name: name, amount: amount, date: date, note: monthlyNote, id: categoryID, expenseCategory: category, image: image)
                expenses.append(newExpense)
                category.expenses?.adding(newExpense)
                notificationScheduler.scheduleExpenseNotifications(expense: newExpense)
                CoreDataStack.shared.saveContext()
            }
        } else {
            for date in repeatedDates {
                let newExpense = Expense(name: name, amount: amount, date: date, note: monthlyNote, id: categoryID, expenseCategory: category, image: nil)
                expenses.append(newExpense)
                category.expenses?.adding(newExpense)
                notificationScheduler.scheduleExpenseNotifications(expense: newExpense)
                CoreDataStack.shared.saveContext()
            }
        }
    }
    
    func createMonthlyExpensesWith(name: String, amount:Double, category: ExpenseCategory, date: Date, note: String, image: Data?, repeatedDuration: [Date]) {
        guard let categoryID = category.id else {return}
        let repeatedDates = repeatedDuration
        var monthlyNote = "*** This is monthly expense. ***"
        if note != "Take a note for your expense here or scan a receipt for expense's detail..." {
            monthlyNote = "*** This is monthly expense. *** \n\(note)"
        }
        if let image = image {
            for date in repeatedDates {
                let newExpense = Expense(name: name, amount: amount, date: date, note: monthlyNote, id: categoryID, expenseCategory: category, image: image)
                expenses.append(newExpense)
                category.expenses?.adding(newExpense)
                CoreDataStack.shared.saveContext()
            }
        } else {
            for date in repeatedDates {
                let newExpense = Expense(name: name, amount: amount, date: date, note: monthlyNote, id: categoryID, expenseCategory: category, image: nil)
                expenses.append(newExpense)
                category.expenses?.adding(newExpense)
                CoreDataStack.shared.saveContext()
            }
        }
    }
    
    // READ
    func fetchAllExpenses() {
        let fetchIncomes = (try? CoreDataStack.shared.context.fetch(fetchRequest)) ?? []
        expenses = fetchIncomes
    }
    
    func fetchExpensesFromTimePeriod(startedTime: Date, endedTime: Date) -> [Expense]{
        var expenses: [Expense] = []
        let fetchRequest: NSFetchRequest<Expense> = NSFetchRequest <Expense>(entityName: "Expense")
        let datePredicate = NSPredicate(format: "date > %@ AND date < %@", startedTime as NSDate, endedTime as NSDate)
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
    
    func fetchExpensesFromTimePeriodAndCategory(startedTime: Date, endedTime: Date, categoryName: String) -> [Expense]{
        var expenses: [Expense] = []
        let fetchRequest: NSFetchRequest<Expense> = NSFetchRequest <Expense>(entityName: "Expense")
        
        let datePredicate = NSPredicate(format: "date > %@ AND date < %@", startedTime as NSDate, endedTime as NSDate)
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
    func updateWith(_ expense: Expense, name: String, amount: Double, category: ExpenseCategory, date: Date, note: String){
        expense.name = name
        expense.amount = NSDecimalNumber(value: amount)
        expense.expenseCategory = category
        expense.note = note
        expense.date = date
        CoreDataStack.shared.saveContext()
    }
    
    func updateExpenseWithNotificaion(_ expense: Expense, name: String, amount: Double, category: ExpenseCategory, date: Date, note: String){
        expense.name = name
        expense.amount = NSDecimalNumber(value: amount)
        expense.expenseCategory = category
        expense.date = date
        expense.note = note
        CoreDataStack.shared.saveContext()
        notificationScheduler.scheduleExpenseNotifications(expense: expense)
    }
    
    // DELETE
    func deleteExpense(_ expense: Expense){
        expense.expenseCategory?.removeFromExpenses(expense)
        CoreDataStack.shared.context.delete(expense)
        notificationScheduler.cancelExpenseNotification(expense: expense)
        CoreDataStack.shared.saveContext()
        fetchAllExpenses()
    }
}
