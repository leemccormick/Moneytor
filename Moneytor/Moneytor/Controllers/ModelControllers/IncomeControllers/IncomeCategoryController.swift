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
    var incomeCategoriesEmoji: [String] = []
    
    private lazy var fetchRequest: NSFetchRequest<IncomeCategory> = {
        let request = NSFetchRequest<IncomeCategory>(entityName: "IncomeCategory")
        request.predicate = NSPredicate(value: true)
        let sectionSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        request.sortDescriptors = sortDescriptors
        return request
    }()
    
    // MARK: - CRUD Methods
    // READ
    func fetchAllIncomeCategories(){
        let fetchAllIncomeCatagories = (try? CoreDataStack.shared.context.fetch(fetchRequest)) ?? []
        incomeCategories = fetchAllIncomeCatagories
    }
    
    // UPDATE
    func generateSectionsAndSumEachIncomeCategory() {
        
        fetchAllIncomeCategories()
        incomeCategoriesSections = []
        incomeCategoriesEmoji = []
        
        var categoryNames: [String] = []
        var section: [Income] = []
        var totalIncomesEachCategory: [Double] = []
        
        for category in incomeCategories {
            let incomeArray = category.incomes?.allObjects as? [Income] ?? []
            var sum = 0.0
            for income in incomeArray {
                sum += income.amount as! Double
                section.append(income)
            }
            incomeCategoriesSections.append(section)
            section = []
            
            
            let nameEmoji = "\(category.nameString) \(category.emojiString)"
           
            categoryNames.append(nameEmoji)
            incomeCategoriesEmoji.append(category.emojiString)
            totalIncomesEachCategory.append(sum)
        }

        let newCategoryDict = Dictionary(uniqueKeysWithValues: zip(categoryNames, totalIncomesEachCategory))
        let sortedDictionary = newCategoryDict.sorted{$0.key < $1.key}
        incomeCategoriesTotalDict = sortedDictionary
    }
}
    
    
//    func createAnotherSectionByFetchingIncome() -> [[Income]]{
//
//        fetchAllIncomeCategories()
//        var sections: [[Income]] = []
//        var incomeCategoriesNameArray: [String] = []
//        var incomeEmojiArray: [String] = []
//
//        for category in incomeCategories {
//            let newIncomeGroup = IncomeController.shared.fetchIncomesByCategory(category: category)
//            sections.append(newIncomeGroup)
//
//            guard let incomeName = category.name,
//                  let incomeEmoji = category.emoji else {return [[]]}
//            incomeCategoriesNameArray.append(incomeName)
//            incomeEmojiArray.append(incomeEmoji)
//
//        }
//
//        var index = 0
//        var totalIncomesArray: [Double] = []
//        for income in sections {
//            var totalIncomeOfEachCategory = 0.0
//            totalIncomeOfEachCategory += income[index].amount as! Double
//            totalIncomesArray.append(totalIncomeOfEachCategory)
//            index += 1
//        }
//
//        let newCategoryDict = Dictionary(uniqueKeysWithValues: zip(incomeCategoriesNameArray, totalIncomesArray))
//        print("----------------- newCategoryDict:: \(newCategoryDict)-----------------")
//
//        return sections
//    }
//
//
    
//}

/* NOTE
 
 
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
