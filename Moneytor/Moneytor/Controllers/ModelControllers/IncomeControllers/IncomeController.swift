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
    
    private lazy var fetchRequest: NSFetchRequest<Income> = {
        let request = NSFetchRequest<Income>(entityName: "Income")
        request.predicate = NSPredicate(value: true)
        let dateSortDescriptor = NSSortDescriptor(key: #keyPath(Income.date), ascending: true)
        request.sortDescriptors = [dateSortDescriptor]
        return request
    }()
    
    
    // MARK: - CRUD Methods
    // CREATE
    func createIncomeWith(name: String, amount: Double, category: IncomeCategory, date: Date) {
        
        guard let categoryID = category.id else {return}
        let newIncome = Income(name: name, amount: amount, date: date, id: categoryID, incomeCategory: category)
        incomes.append(newIncome)
        category.incomes?.adding(newIncome)
        CoreDataStack.shared.saveContext()
    }
    
    // READ
    func fetchAllIncomes() {
        let fetchIncomes = (try? CoreDataStack.shared.context.fetch(fetchRequest)) ?? []
        incomes = fetchIncomes
    }
    
    
    //    func fetchIncomesByCategory(category: IncomeCategory ) -> [Income]{
    //
    //        let categories = fetchAllIncomeCategories()
    //        for category in categories {
    //            let fetchRequest: NSFetchRequest<Income> = NSFetchRequest <Income>(entityName: "Income")
    //
    //            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    //           // fetchRequest.predicate = NSPredicate(format: "incomeCategory.name = %@", arguments: category.name)
    //
    //        }
    //    }
    //
    
    func fetchAllIncomeCategories() -> [IncomeCategory]{
        
        // var fromdate = "\(self.appdel.fromdate) 00:00" // add hours and mins to fromdate
        //  var todate = "\(self.appdel.todate) 23:59" // add hours and mins to todate
        
        var incomeCategories: [IncomeCategory] = []
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "IncomeCategory")
        fetchRequest.predicate = NSPredicate(value: true)
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        let fetchAllIncomeCatagories = (try? CoreDataStack.shared.context.fetch(fetchRequest)) ?? []
        incomeCategories = fetchAllIncomeCatagories as! [IncomeCategory]
        
        let now = Date()
        print(now)
        let nowString = now.dateToString(format: .fullNumericTimestamp)
        let oneWeekAgoDate = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        let oneWeekAgoDateString = oneWeekAgoDate.dateToString(format: .fullNumeric)
        //        let oneMonthAgoDate = Calendar.current.date(byAdding: .month, value: -1, to: now)!
        //        let oneDayAgoDate = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        //        let oneYearAgoDate = Calendar.current.date(byAdding: .year, value: -1, to: now)!
        //
        
        for incomeCategory in incomeCategories {
            let fetchRequest: NSFetchRequest<Income> = NSFetchRequest <Income>(entityName: "Income")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
            
            //  let predicate2 = NSPredicate(format: "%@ <= date AND date <= %@", nowString, oneWeekAgoDateString)
            
            let predicate1 = NSPredicate(format: "incomeCategory.name =%@", incomeCategory.name!)
            let predicate2 = NSPredicate(format: "date > %@ AND date < %@", oneWeekAgoDate as NSDate, now as NSDate)
            let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
            fetchRequest.predicate = compound
            
            
            do {
                let fetchIncomes = try(CoreDataStack.shared.context.fetch(fetchRequest))
                incomes.append(contentsOf: fetchIncomes)
                
                
                
            } catch {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
            
        }
        
        incomes = incomes.sorted(by: {$0.date!.compare($1.date!) == .orderedDescending})
        //print(incomes.count)
        print("----------------- incomes.countincomes.count: \(incomes.count)-----------------")
        
        for income in incomes {
            print("-----In incomes.count------------ \(income.incomeCategory?.emoji):: \(income.incomeDateText)-----------------")
        }
        
        
        return incomeCategories
        
    }
    
    //______________________________________________________________________________________
    
    func fetchIncomesWeekly() -> [Income]{
        var incomes: [Income] = []
        let now = Date()
        print(now)
        let oneWeekAgoDate = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        let fetchRequest: NSFetchRequest<Income> = NSFetchRequest <Income>(entityName: "Income")
        
        let predicate = NSPredicate(format: "date > %@ AND date < %@", oneWeekAgoDate as NSDate, now as NSDate)
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "incomeCategory.name", ascending: true)]
        do {
            let fetchIncomes = try(CoreDataStack.shared.context.fetch(fetchRequest))
            incomes.append(contentsOf: fetchIncomes)
        } catch {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
        print("----------------- incomes.countincomes.count: \(incomes.count)-----------------")
        for income in incomes {
            print("-----In incomes.count------------ \(income.incomeCategory?.emoji):: \(income.incomeDateText)-----------------")
        }
        return incomes
    }
    
    
    
    func fetchIncomesFromTimePeriod(_ time: Date) -> [Income]{
        var incomes: [Income] = []
        let now = Date()
       // let oneWeekAgoDate = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        let fetchRequest: NSFetchRequest<Income> = NSFetchRequest <Income>(entityName: "Income")
        
        let predicate = NSPredicate(format: "date > %@ AND date < %@", time as NSDate, now as NSDate)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "incomeCategory.name", ascending: true)]
        do {
            let fetchIncomes = try(CoreDataStack.shared.context.fetch(fetchRequest))
            incomes.append(contentsOf: fetchIncomes)
        } catch {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
        print("----------------- incomes.countincomes.count: \(incomes.count)-----------------")
        for income in incomes {
            print("-----In incomes.count------------ \(income.incomeCategory?.emoji):: \(income.incomeDateText)-----------------")
        }
        return incomes
    }
    
    
    func fetchIncomesFromTimePeriodAndCategory(_ time: Date, categoryName: String) -> [Income]{
        var incomes: [Income] = []
        let now = Date()
       // let oneWeekAgoDate = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        let fetchRequest: NSFetchRequest<Income> = NSFetchRequest <Income>(entityName: "Income")
        
        let datePredicate = NSPredicate(format: "date > %@ AND date < %@", time as NSDate, now as NSDate)
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
        print("----------------- incomes.countincomes.count: \(incomes.count)-----------------")
        for income in incomes {
            print("-----In incomes.count------------ \(income.incomeCategory?.emoji):: \(income.incomeDateText)-----------------")
        }
        return incomes
    }
    
    
    
    
    
    //______________________________________________________________________________________

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
        income.incomeCategory?.removeFromIncomes(income)
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
