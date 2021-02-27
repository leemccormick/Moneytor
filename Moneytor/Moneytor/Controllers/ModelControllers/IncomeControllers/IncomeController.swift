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
   
    var sections: [[IncomeCategory]] = []
    var numberOfSection: Int = 0
    
    private lazy var fetchRequest: NSFetchRequest<Income> = {
        let request = NSFetchRequest<Income>(entityName: "Income")
        request.predicate = NSPredicate(value: true)
        return request
    }()
    
    
    
    
    // MARK: - CRUD Methods
    // CREATE
    func createIncomeWith(name: String, amount: Double, category: IncomeCategory, date: Date) {
        let newIncome = Income(name: name, amount: amount, date: date, incomeCategory: category)
        incomes.append(newIncome)
        CoreDataStack.shared.saveContext()
    }
    
    
    
    // READ
    func fetchAllIncomes() {
        let fetchIncomes = (try? CoreDataStack.shared.context.fetch(fetchRequest)) ?? []
        incomes = fetchIncomes
    }
    
    
    // UPDATE
    func updateWith(_ income: Income, name: String, amount: Double, category: IncomeCategory, date: Date){
        income.name = name
        income.amount = NSDecimalNumber(value: amount)
        income.incomeCategory = category
        income.date = date
        CoreDataStack.shared.saveContext()
    }
    
    // DELETE
    func deleteIncome(_ income: Income){
        CoreDataStack.shared.context.delete(income)
        CoreDataStack.shared.saveContext()
        fetchAllIncomes()
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
