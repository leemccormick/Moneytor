//
//  IncomeController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/23/21.
//

import CoreData

class IncomeController {
    
    // MARK: - Properties
    static let shared = IncomeController()
    var incomes: [Income] = []
    let notificationScheduler = NotificationScheduler()
    
    private lazy var fetchRequest: NSFetchRequest<Income> = {
        let request = NSFetchRequest<Income>(entityName: "Income")
        request.predicate = NSPredicate(value: true)
        let dateSortDescriptor = NSSortDescriptor(key: #keyPath(Income.date), ascending: false)
        request.sortDescriptors = [dateSortDescriptor]
        return request
    }()
    
    // MARK: - CRUD Methods
    // CREATE
    func createIncomeWith(name: String, amount: Double, category: IncomeCategory, date: Date, note: String, image: Data?) {
        guard let categoryID = category.id else {return}
        if let image = image {
            let newIncome = Income(name: name, amount: amount, date: date, note: note, id: categoryID, incomeCategory: category, image: image)
            incomes.append(newIncome)
            category.incomes?.adding(newIncome)
            CoreDataStack.shared.saveContext()
        } else {
            let newIncome = Income(name: name, amount: amount, date: date, note: note, id: categoryID, incomeCategory: category, image: nil)
            incomes.append(newIncome)
            category.incomes?.adding(newIncome)
            CoreDataStack.shared.saveContext()
        }
    }
    
    func createIncomeAndNotificationWith(name: String, amount: Double, category: IncomeCategory, date: Date, note: String, image: Data?)  {
        guard let categoryID = category.id else {return}
        if let image = image {
            let newIncome = Income(name: name, amount: amount, date: date, note: note, id: categoryID, incomeCategory: category, image: image)
            incomes.append(newIncome)
            category.incomes?.adding(newIncome)
            CoreDataStack.shared.saveContext()
            notificationScheduler.scheduleIncomeNotifications(income: newIncome)
        } else {
            let newIncome = Income(name: name, amount: amount, date: date, note: note, id: categoryID, incomeCategory: category, image: nil)
            incomes.append(newIncome)
            category.incomes?.adding(newIncome)
            CoreDataStack.shared.saveContext()
            notificationScheduler.scheduleIncomeNotifications(income: newIncome)
        }
    }
    
    func createMonthlyIncomesAndNotificationsWith(repeatDuration: [Date],name: String, amount: Double, category: IncomeCategory, date: Date, note: String, image: Data?)  {
        guard let categoryID = category.id else {return}
        let repeatedDates = repeatDuration
        var monthlyNote = "*** This is monthly income. ***"
        if note != "Take a note for your income here or scan document for income's detail..." {
            monthlyNote = "*** This is monthly income. *** \n\(note)"
        }
        if let image = image {
            for date in repeatedDates {
                let newIncome = Income(name: name, amount: amount, date: date, note: monthlyNote, id: categoryID, incomeCategory: category, image: image)
                incomes.append(newIncome)
                category.incomes?.adding(newIncome)
                notificationScheduler.scheduleIncomeNotifications(income: newIncome)
                CoreDataStack.shared.saveContext()
            }
        } else {
            for date in repeatedDates {
                let newIncome = Income(name: name, amount: amount, date: date, note: monthlyNote, id: categoryID, incomeCategory: category, image: nil)
                incomes.append(newIncome)
                category.incomes?.adding(newIncome)
                notificationScheduler.scheduleIncomeNotifications(income: newIncome)
                CoreDataStack.shared.saveContext()
            }
        }
    }
    
    func createMonthlyIncomesWith(name: String, amount:Double, category: IncomeCategory, date: Date, note: String, image: Data?, repeatedDuration: [Date]) {
        guard let categoryID = category.id else {return}
        let repeatedDates = repeatedDuration
        var monthlyNote = "*** This is monthly income. ***"
        if note != "Take a note for your income here or scan document for income's detail..." {
            monthlyNote = "*** This is monthly income. *** \n\(note)"
        }
        if let image = image {
            for date in repeatedDates {
                let newIncome = Income(name: name, amount: amount, date: date, note: monthlyNote, id: categoryID, incomeCategory: category, image: image)
                incomes.append(newIncome)
                category.incomes?.adding(newIncome)
                CoreDataStack.shared.saveContext()
            }
        } else {
            for date in repeatedDates {
                let newIncome = Income(name: name, amount: amount, date: date, note: monthlyNote, id: categoryID, incomeCategory: category, image: image)
                incomes.append(newIncome)
                category.incomes?.adding(newIncome)
                CoreDataStack.shared.saveContext()
            }
        }
    }
    
    // READ
    func fetchAllIncomes() {
        let fetchIncomes = (try? CoreDataStack.shared.context.fetch(fetchRequest)) ?? []
        incomes = fetchIncomes
    }
    
    func fetchIncomesFromTimePeriod(startedTime: Date, endedTime: Date) -> [Income]{
        var incomes: [Income] = []
        let fetchRequest: NSFetchRequest<Income> = NSFetchRequest <Income>(entityName: "Income")
        let datePredicate = NSPredicate(format: "date > %@ AND date < %@", startedTime as NSDate, endedTime as NSDate)
        fetchRequest.predicate = datePredicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            let fetchIncomes = try(CoreDataStack.shared.context.fetch(fetchRequest))
            incomes.append(contentsOf: fetchIncomes)
        } catch {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
        return incomes
    }
    
    func fetchIncomesFromTimePeriodAndCategory(startedTime: Date, endedTime: Date, categoryName: String) -> [Income]{
        var incomes: [Income] = []
        let fetchRequest: NSFetchRequest<Income> = NSFetchRequest <Income>(entityName: "Income")
        
        let datePredicate = NSPredicate(format: "date > %@ AND date < %@", startedTime as NSDate, endedTime as NSDate)
        let categoryPredicate = NSPredicate(format: "incomeCategory.name == %@", categoryName)
        
        let finalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, categoryPredicate])
        fetchRequest.predicate = finalPredicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "incomeCategory.name", ascending: true)]
        do {
            let fetchIncomes = try(CoreDataStack.shared.context.fetch(fetchRequest))
            incomes.append(contentsOf: fetchIncomes)
        } catch {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
        return incomes
    }
    
    // UPDATE
    func updateWith(_ income: Income, name: String, amount: Double, category: IncomeCategory, date: Date, note: String){
        income.name = name
        income.amount = NSDecimalNumber(value: amount)
        income.incomeCategory = category
        income.date = date
        income.note = note
        CoreDataStack.shared.saveContext()
    }
    
    func updateIncomeWithNotification(_ income: Income, name: String, amount: Double, category: IncomeCategory, date: Date, note: String){
        income.name = name
        income.amount = NSDecimalNumber(value: amount)
        income.incomeCategory = category
        income.date = date
        income.note = note
        CoreDataStack.shared.saveContext()
        notificationScheduler.scheduleIncomeNotifications(income: income)
    }
    
    // DELETE
    func deleteIncome(_ income: Income){
        income.incomeCategory?.removeFromIncomes(income)
        CoreDataStack.shared.context.delete(income)
        notificationScheduler.cancelIncomeNotification(income: income)
        CoreDataStack.shared.saveContext()
        fetchAllIncomes()
    }
    
    // MARK: - Subscribe For Romote Notifications
    func subscribeForRomoteNotifications(completion: @escaping (Bool) -> Void ) {
        let allIncomesPredicate = NSPredicate(value: true)
        let subscription = CKQuerySubscription(recordType: "CD_Income", predicate: allIncomesPredicate, options: .firesOnRecordUpdate)
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "MONEYTOR!"
        notificationInfo.alertBody = "MONEYTOR APP IS USING WITH ANOTHER DEVICE FROM SOMEWHERE ELSE."
        notificationInfo.soundName = "default"
        notificationInfo.shouldBadge = true
        subscription.notificationInfo = notificationInfo
        
        CKContainer.default().privateCloudDatabase.save(subscription) { (_, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(false)
            }
            completion(true)
        }
    }
}

