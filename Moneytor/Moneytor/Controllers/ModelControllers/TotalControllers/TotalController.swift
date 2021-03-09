//
//  TotalController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/25/21.
//

import Foundation

class TotalController {
    
    static let shared = TotalController()
    var totalBalance: Double = 0.0
    var totalIncome: Double = 0.0
    var totalExpense: Double = 0.0
    var totalBalanceString: String = "$00.00"
    var totalIncomeString: String = "$00.00"
    var totalExpenseString: String = "$00.00"
    
    var totalIncomeSearchResults: Double = 0.0
    var totalIncomeSearchResultsInString: String = "$00.00"
    var totalExpenseSearchResults: Double = 0.0
    var totalExpenseSearchResultsInString: String = "$00.00"
    
    var totalIncomeBySpecificTime: Double = 00.00
    var totalIncomeBySpecificTimeString: String = "$00.00"
    var totalExpenseBySpecificTime: Double = 00.00
    var totalExpensesBySpecificTimeString: String = "$00.00"
    var totalBalanceBySpecificTime: Double = 00.00
    var totalBalanceBySpecificTimeString: String = "$00.00"
    
    var totalIncomeDict = [Dictionary<String, Double>.Element]()
    var totalExpenseDictByMonthly = [Dictionary<String, Double>.Element]()

    let daily = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    let weekly = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    let monthly = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    let yearly = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
    
    
    func calculateTotalIncome() {
        IncomeController.shared.fetchAllIncomes()
        var sumIncome = 0.0
      let incomes =  IncomeController.shared.incomes
        for income in incomes {
            let incomeAmount = income.amount as? Double ?? 0.0
            sumIncome += incomeAmount
        }
        totalIncome = sumIncome
        totalIncomeString =  AmountFormatter.currencyInString(num: totalIncome)
    }
    
    func calculateTotalIncomesBySpecificTime(_ time: Date) {
        let incomes = IncomeController.shared.fetchIncomesFromTimePeriod(time)
        var sumIncome = 0.0
    //  let incomes =  IncomeController.shared.incomes
        for income in incomes {
            let incomeAmount = income.amount as? Double ?? 0.0
            sumIncome += incomeAmount
        }
        totalIncomeBySpecificTime = sumIncome
        totalIncomeBySpecificTimeString =  AmountFormatter.currencyInString(num: totalIncomeBySpecificTime)
    }
    
    func calculateTotalExpensesBySpecificTime(_ time: Date) {
        let expenses = ExpenseController.shared.fetchExpensesFromTimePeriod(time)

        var sumExpenses = 0.0
    //  let incomes =  IncomeController.shared.incomes
        for expense in expenses {
            let expenseAmount = expense.amount as? Double ?? 0.0
            sumExpenses += expenseAmount
        }
        
        totalExpenseBySpecificTime = sumExpenses
        totalExpensesBySpecificTimeString =  AmountFormatter.currencyInString(num: totalExpenseBySpecificTime)
    }
    
    func calculateTotalBalanceBySpecificTime(_ time: Date) {
        calculateTotalIncomesBySpecificTime(time)
        calculateTotalExpensesBySpecificTime(time)
        
        totalBalanceBySpecificTime = totalIncomeBySpecificTime - totalExpenseBySpecificTime
        totalBalanceBySpecificTimeString =  AmountFormatter.currencyInString(num: totalBalanceBySpecificTime)
    }
    
    
    func calculateTotalExpense() {
        ExpenseController.shared.fetchAllExpenses()
        var sumExpense = 0.0
      let expenses =  ExpenseController.shared.expenses
        for expense in expenses {
            let expenseAmount = expense.amount as? Double ?? 0.0
            sumExpense += expenseAmount
        }
        totalExpense = sumExpense
        totalExpenseString =  AmountFormatter.currencyInString(num: totalExpense)
    }
    
    func calculateTotalBalance() {
        calculateTotalIncome()
        calculateTotalExpense()
        totalBalance = totalIncome - totalExpense
        totalBalanceString =  AmountFormatter.currencyInString(num: totalBalance)
    }
    
    func calculateTotalIncomeFrom(searchArrayResults: [Income]) {
        IncomeController.shared.fetchAllIncomes()
        var sum = 0.0
        let results =  searchArrayResults
        for result in results {
            let amount = result.amount as? Double ?? 0.0
            sum += amount
        }
        totalIncomeSearchResults = sum
        totalIncomeSearchResultsInString =  AmountFormatter.currencyInString(num: totalIncomeSearchResults)
    }
    
    func calculateTotalExpenseFrom(searchArrayResults: [Expense]) {
        ExpenseController.shared.fetchAllExpenses()
        var sum = 0.0
        let results =  searchArrayResults
        for result in results {
            let amount = result.amount as? Double ?? 0.0
            sum += amount
        }
        totalExpenseSearchResults = sum
        totalExpenseSearchResultsInString =  AmountFormatter.currencyInString(num: totalExpenseSearchResults)
    }
    
    func generateTotalIncomeDictByMonthly(){
        let incomes = IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(IncomeCategoryController.shared.monthly)
        totalIncomeDict = IncomeCategoryController.shared.generateCategoryDictionaryByIncomesAndReturnDict(sections: incomes)
    }
    
    func generateTotalExpenseDictByMonthly(){
        let expenses = ExpenseCategoryController.shared.generateSectionsCategoiesByTimePeriod(ExpenseCategoryController.shared.monthly)
        
        totalExpenseDictByMonthly = ExpenseCategoryController.shared.generateCategoryDictionaryByExpensesAndReturnDict(sections: expenses)
    }
    
    
    func generateTotalExpenseDictByTime(_ time: Date) -> [Dictionary<String, Double>.Element] {
        let expenses = ExpenseCategoryController.shared.generateSectionsCategoiesByTimePeriod(time)
        
        let newTotalExpenseDict = ExpenseCategoryController.shared.generateCategoryDictionaryByExpensesAndReturnDict(sections: expenses)
    
        print("-------------------- newTotalExpenseDict \(newTotalExpenseDict) in \(#function) : ----------------------------\n)")
        return newTotalExpenseDict
    }
   
}
    
/* NOTE
 func calculateTotalIncomeByTime(_ time: Date) {
        let incomes = IncomeController.shared.fetchIncomesFromTimePeriod(time)
    }
 //______________________________________________________________________________________
 */
