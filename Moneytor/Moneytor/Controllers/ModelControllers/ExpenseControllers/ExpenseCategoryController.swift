//
//  ExpenseCategory.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/24/21.
//

import CoreData

class ExpenseCategoryController {
    
    // MARK: - Properties
    static let shared = ExpenseCategoryController()
    var expenseCategories: [ExpenseCategory] = []
    var expenseCategoriesSections: [[Expense]] = []
    var expenseCategoriesTotalDict = [Dictionary<String, Double>.Element]()
    let daily = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    let weekly = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    let monthly = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    let yearly = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
    
    private lazy var fetchRequest: NSFetchRequest<ExpenseCategory> = {
        let request = NSFetchRequest<ExpenseCategory>(entityName: "ExpenseCategory")
        request.predicate = NSPredicate(value: true)
        let sectionSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        request.sortDescriptors = sortDescriptors
        return request
    }()
    
    // MARK: - CRUD Methods
    func createExpenseDefaultCategories(name: String, emoji: String) -> ExpenseCategory? {
        let newExpenseCategory = ExpenseCategory(name: name, emoji: emoji, expenses: nil)
        var isDuplicatedCategory: Bool = false
        for expenseCategory in expenseCategories {
            if newExpenseCategory.nameString.lowercased() == expenseCategory.nameString.lowercased() {
                isDuplicatedCategory = true
            } else {
                isDuplicatedCategory = false
            }
        }
        var returnNewExpenseCategory: ExpenseCategory?
        if isDuplicatedCategory {
            print("\n===================ERROR! DUPLICATED CATAGORY IN \(#function) ======================\n")
        } else {
            expenseCategories.append(newExpenseCategory)
            CoreDataStack.shared.saveContext()
            returnNewExpenseCategory = newExpenseCategory
        }
        
        return returnNewExpenseCategory
    }
    
    // READ
    func fetchAllExpenseCategories(){
        let fetchAllExpenseCatagories = (try? CoreDataStack.shared.context.fetch(fetchRequest)) ?? []
        expenseCategories = fetchAllExpenseCatagories
    }
    
    // UPDATE
    func generateSectionsCategoiesByTimePeriod(start: Date, end: Date) -> [[Expense]]  {
        fetchAllExpenseCategories()
        var newExpenseCategoriesSections: [[Expense]] = []
        for expenseCategory in expenseCategories {
            if let expenseCategoryName = expenseCategory.name {
                let newCategorySection = ExpenseController.shared.fetchExpensesFromTimePeriodAndCategory(startedTime: start, endedTime: end, categoryName: expenseCategoryName)
                let sortedCategory = newCategorySection.sorted(by: {$0.date!.compare($1.date!) == .orderedDescending})
                newExpenseCategoriesSections.append(sortedCategory.removeDuplicates())
            }
        }
        return newExpenseCategoriesSections
    }
    
    func generateCategoryDictionaryByExpensesAndReturnDict(sections: [[Expense]]) -> [Dictionary<String, Double>.Element] {
        var categoryNames: [String] = []
        var totalExpensesEachCategory: [Double] = []
        
        for expense in sections {
            let expenseCategorySum = expense.map({$0.amount as! Double}).reduce(0.0){$0 + $1}
            totalExpensesEachCategory.append(expenseCategorySum)
            let expenseCategoryName = expense.map({$0.expenseCategory?.name ?? ""}).removeDuplicates()
            let expenseCategoryEmoji = expense.map({$0.expenseCategory?.emoji ?? ""}).removeDuplicates()
            
            if let categoryNameArray = expenseCategoryName.first, !categoryNameArray.isEmpty,
               let categoryEmojiArray = expenseCategoryEmoji.first, !categoryEmojiArray.isEmpty {
                let nameEmoji = "\(categoryEmojiArray) \(categoryNameArray.capitalized) "
                categoryNames.append(nameEmoji)
            }
        }
        
        for total in totalExpensesEachCategory {
            if total == 0.0 {
                let totalToDelete = totalExpensesEachCategory.firstIndex(of: total)
                totalExpensesEachCategory.remove(at: totalToDelete!)
            }
        }
        let newCategoryDict = Dictionary(uniqueKeysWithValues: zip(categoryNames.removeDuplicates(), totalExpensesEachCategory))
        let sortedDictionary = newCategoryDict.sorted{$0.key < $1.key}
        return sortedDictionary
    }
}


