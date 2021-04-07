//
//  IncomeCategoryController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/24/21.
//

import CoreData

class IncomeCategoryController {
    
    // MARK: - Properties
    static let shared = IncomeCategoryController()
    var incomeCategories: [IncomeCategory] = []
    var incomeCategoriesSections: [[Income]] = []
    var incomeCategoriesTotalDict = [Dictionary<String, Double>.Element]()
    let daily = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    let weekly = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    let monthly = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    let yearly = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
    
    private lazy var fetchRequest: NSFetchRequest<IncomeCategory> = {
        let request = NSFetchRequest<IncomeCategory>(entityName: "IncomeCategory")
        request.predicate = NSPredicate(value: true)
        let sectionSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        request.sortDescriptors = sortDescriptors
        return request
    }()
    
    // MARK: - CRUD Methods
    func createIncomeDefaultCategories(name: String, emoji: String) -> IncomeCategory? {
    let newIncomeCategory = IncomeCategory(name: name, emoji: emoji, incomes: nil)
        var isDuplicatedCategory: Bool = false
        for incomeCategory in incomeCategories {
            if newIncomeCategory.nameString.lowercased() == incomeCategory.nameString.lowercased() {
                isDuplicatedCategory = true
            } else {
                isDuplicatedCategory = false
            }
        }
        var returnNewIncomeCategory: IncomeCategory?
        if isDuplicatedCategory {
            print("\n===================ERROR! DUPLICATED CATAGORY IN \(#function) ======================\n")
        } else {
        incomeCategories.append(newIncomeCategory)
                           CoreDataStack.shared.saveContext()
            returnNewIncomeCategory = newIncomeCategory
        }
        return returnNewIncomeCategory
    }
    
    // READ
    func fetchAllIncomeCategories(){
        let fetchAllIncomeCatagories = (try? CoreDataStack.shared.context.fetch(fetchRequest)) ?? []
        incomeCategories = fetchAllIncomeCatagories
        print("--------------------incomeCategories : \(incomeCategories.count) in \(#function) : ----------------------------\n)")
    }
    
    func generateSectionsCategoiesByTimePeriod(start: Date, end: Date) -> [[Income]]  {
        fetchAllIncomeCategories()
        var newIncomeCategoriesSections: [[Income]] = []
        
        for incomeCategory in incomeCategories {
            if let incomeCategoryName = incomeCategory.name {
                let newCategorySection = IncomeController.shared.fetchIncomesFromTimePeriodAndCategory(startedTime: start, endedTime: end, categoryName: incomeCategoryName)
                let sortedCategory = newCategorySection.sorted(by: {$0.date!.compare($1.date!) == .orderedDescending})
                newIncomeCategoriesSections.append(sortedCategory.removeDuplicates())
            }
        }
        return newIncomeCategoriesSections
    }
    
    func generateCategoryDictionaryByIncomesAndReturnDict(sections: [[Income]]) -> [Dictionary<String, Double>.Element] {
        //incomeCategoriesTotalDict = []
        var categoryNames: [String] = []
        var totalIncomesEachCategory: [Double] = []
        
        for incomes in sections {
            let incomeCategorySum = incomes.map({$0.amount as! Double}).reduce(0.0){$0 + $1}
            totalIncomesEachCategory.append(incomeCategorySum)
            let incomeCategoryName = incomes.map({$0.incomeCategory?.name ?? ""}).removeDuplicates()
            let incomeCategoryEmoji = incomes.map({$0.incomeCategory?.emojiString ?? ""}).removeDuplicates()
            
            if let categoryNameArray = incomeCategoryName.first, !categoryNameArray.isEmpty,
               let categoryEmojiArray = incomeCategoryEmoji.first, !categoryEmojiArray.isEmpty {
                let nameEmoji = "\(categoryEmojiArray) \(categoryNameArray.capitalized) "
                categoryNames.append(nameEmoji)
            }
        }
        
        for total in totalIncomesEachCategory {
            if total == 0.0 {
                let totalToDelete = totalIncomesEachCategory.firstIndex(of: total)
                totalIncomesEachCategory.remove(at: totalToDelete!)
            }
        }
        
        let newCategoryDict = Dictionary(uniqueKeysWithValues: zip(categoryNames.removeDuplicates(), totalIncomesEachCategory))
        let sortedDictionary = newCategoryDict.sorted{$0.key < $1.key}
        return sortedDictionary
    }
}

/* NOTE
 
 func generateSectionsAndSumEachIncomeCategory() {
         fetchAllIncomeCategories()
       //  incomeCategoriesSections = []
         
         var categoryNames: [String] = []
         var section: [Income] = []
         var totalIncomesEachCategory: [Double] = []
         
         for category in incomeCategories {
             let incomeArray = category.incomes?.allObjects as? [Income] ?? []
             let newIncomeArray = incomeArray.sorted(by: {$0.date!.compare($1.date!) == .orderedDescending})
             
             var sum = 0.0
             for income in newIncomeArray {
                 sum += income.amount as! Double
                 section.append(income)
             }
             incomeCategoriesSections.append(section)
             section = []
             
             let nameEmoji = "\(category.nameString) \(category.emojiString)"
             categoryNames.append(nameEmoji)
             totalIncomesEachCategory.append(sum)
         }
         
         let newCategoryDict = Dictionary(uniqueKeysWithValues: zip(categoryNames.removeDuplicates(), totalIncomesEachCategory.removeDuplicates()))
         let sortedDictionary = newCategoryDict.sorted{$0.key < $1.key}
         incomeCategoriesTotalDict = sortedDictionary
     }

 
 
 func generateCategoryDictionaryBy(sections: [[Income]]) {
 var categoryNames: [String] = []
 var totalIncomesEachCategory: [Double] = []
 
 for incomes in sections {
 
 let incomeCategorySum = incomes.map({$0.amount as! Double}).reduce(0.0){$0 + $1}
 totalIncomesEachCategory.append(incomeCategorySum)
 let incomeCategoryName = incomes.map({$0.incomeCategory?.name ?? ""}).removeDuplicates()
 let incomeCategoryEmoji = incomes.map({$0.incomeCategory?.emojiString ?? ""}).removeDuplicates()
 
 guard let categoryNameArray = incomeCategoryName.first, !categoryNameArray.isEmpty,
 let categoryEmojiArray = incomeCategoryEmoji.first, !categoryEmojiArray.isEmpty else {return}
 // if !incomeCategoryName.isEmpty {
 let nameEmoji = "\(categoryEmojiArray) \(categoryNameArray.capitalized) "
 categoryNames.append(nameEmoji)
 // }
 }
 
 
 // print("\n-------------------- categoryNames: \(categoryNames) :: totalIncomesEachCategory:: \(totalIncomesEachCategory)in \(#function) : ----------------------------\n)")
 // print("----------------- totalIncomesEachCategory:: \(totalIncomesEachCategory)-----------------")
 
 let newCategoryDict = Dictionary(uniqueKeysWithValues: zip(categoryNames, totalIncomesEachCategory))
 
 let sortedDictionary = newCategoryDict.sorted{$0.key < $1.key}
 print("--------------------sortedDictionary : \(sortedDictionary) in \(#function) : ----------------------------\n)")
 incomeCategoriesTotalDict = sortedDictionary
 }
 
 
 // CREATE
 func createIncomeCategories(name: String, emoji: String) {
 let newIncomeCategory = IncomeCategory(name: name, emoji: emoji)
 
 for incomeCategory in incomeCategories {
 if newIncomeCategory == incomeCategory {
 print("==================\n :: NEW INCOME CATEGORY IS DUPICATED. \(newIncomeCategory.name)\n=======================")
 
 } else {
 
 incomeCategories.append(newIncomeCategory)
 }
 }
 
 
 // incomeCategories.removeDuplicates()
 CoreDataStack.shared.saveContext()
 }
 
 
 
 
 var incomeCategories: [IncomeCategory] = [
 IncomeCategory(name: "_other", emoji: "💵", incomes: nil, id: "E46573D3-C3C3-48B0-99F5-1DF6B1D8FFF1"),
 IncomeCategory(name: "salary", emoji: "💳", incomes: nil, id: "A5577198-7298-4E8A-BBDC-6CFA07BB4271"),
 IncomeCategory(name: "saving account", emoji: "💰", incomes: nil, id: "961F3F7E-E03E-4D26-B36C-B7928466F403"),
 IncomeCategory(name: "checking account", emoji: "🏧", incomes: nil, id: "9758F6A5-90F4-454A-8B8E-DFF6E6379AC0")
 ]
 //______________________________________________________________________________________
 */


