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
    func createIncomeWith(name: String, amount: Double, category: IncomeCategory, date: Date, note: String) {
        guard let categoryID = category.id else {return}
        let newIncome = Income(name: name, amount: amount, date: date, note: note, id: categoryID, incomeCategory: category)
        incomes.append(newIncome)
        category.incomes?.adding(newIncome)
        CoreDataStack.shared.saveContext()
    }
    
    func createIncomeAndNotificationWith(name: String, amount: Double, category: IncomeCategory, date: Date, note: String)  {
        guard let categoryID = category.id else {return}
        let newIncome = Income(name: name, amount: amount, date: date, note: note, id: categoryID, incomeCategory: category)
        incomes.append(newIncome)
        category.incomes?.adding(newIncome)
        CoreDataStack.shared.saveContext()
        notificationScheduler.scheduleIncomeNotifications(income: newIncome)
    }
    
    // READ
    func fetchAllIncomes() {
        let fetchIncomes = (try? CoreDataStack.shared.context.fetch(fetchRequest)) ?? []
        incomes = fetchIncomes
    }
    
    func fetchIncomesFromTimePeriod(startedTime: Date, endedTime: Date) -> [Income]{
           var incomes: [Income] = []
           //let now = Date()
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

/* NOTE
 
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
       return incomes
   }
   
//    func fetchIncomesFromTimePeriod(_ time: Date) -> [Income]{
//        var incomes: [Income] = []
//        let now = Date()
//       // let oneWeekAgoDate = Calendar.current.date(byAdding: .day, value: -7, to: now)!
//        let fetchRequest: NSFetchRequest<Income> = NSFetchRequest <Income>(entityName: "Income")
//
//        let predicate = NSPredicate(format: "date > %@ AND date < %@", time as NSDate, now as NSDate)
//        fetchRequest.predicate = predicate
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "incomeCategory.name", ascending: true)]
//        do {
//            let fetchIncomes = try(CoreDataStack.shared.context.fetch(fetchRequest))
//            incomes.append(contentsOf: fetchIncomes)
//        } catch {
//            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
//        }
//        print("----------------- incomes.countincomes.count: \(incomes.count)-----------------")
//        for income in incomes {
//            print("-----In incomes.count------------ \(income.incomeCategory?.emoji):: \(income.incomeDateText)-----------------")
//        }
//        return incomes
//    }
//
 func fetchAllIncomeCategories() -> [IncomeCategory]{
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
       return incomeCategories
   }
   
 
 
 //______________________________________________________________________________________
 */
