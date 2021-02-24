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
    var incomes:[Income] = []
    private lazy var fetchRequest: NSFetchRequest<Income> = {
        let request = NSFetchRequest<Income>(entityName: "Income")
        request.predicate = NSPredicate(value: true)
        return request
    }()
    
    // MARK: - CRUD Methods
    // CREATE
    func createIncome(name: String, amount: Double, category: String, date: Date) {
        let newIncome = Income(name: name, amount: amount, category: category, date: date)
        incomes.append(newIncome)
        CoreDataStack.shared.saveContext()
    }
    
    // READ
    func fetchAllIncomes() {
        let fetchIncomes = (try? CoreDataStack.shared.context.fetch(fetchRequest)) ?? []
        incomes = fetchIncomes
    }
    
    // UPDATE
    func updateIncome(income: Income, name: String, amount: Double, category: String, date: Date){
        income.name = name
        income.amount = NSDecimalNumber(value: amount)
        income.category = category
        income.date = date
        CoreDataStack.shared.saveContext()
    }
    
    // DELETE
    func deleteIncome(income: Income){
        CoreDataStack.shared.context.delete(income)
        CoreDataStack.shared.saveContext()
    }

// MARK: - Subscribe For Romote Notifications
func subscribeForRomoteNotifications(completion: @escaping (Bool) -> Void ) {
    
    let allIncomesPredicate = NSPredicate(value: true)
    let subscription = CKQuerySubscription(recordType: "CD_Income", predicate: allIncomesPredicate, options: .firesOnRecordUpdate)
    let notificationInfo = CKSubscription.NotificationInfo()
    notificationInfo.title = "MONEYTOR!"
    notificationInfo.alertBody = "INCOME is updating from somewhere."
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
