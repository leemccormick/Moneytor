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

