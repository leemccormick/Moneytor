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
        print("\n ::: TOTAL INCOME : \(totalIncome)")
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

        print("\n ::: TOTAL Expense : \(totalExpense)")
    }
    
    func calculateTotalBalance() {
        calculateTotalIncome()
        calculateTotalExpense()
        totalBalance = totalIncome - totalExpense
        totalBalanceString =  AmountFormatter.currencyInString(num: totalBalance)
        print("\n ::: TOTAL Balance : \(totalBalance)")
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

        print("\n ::: TOTAL INCOME SEARCHRESULT : \(totalIncomeSearchResults)")
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

        print("\n ::: TOTAL EXPENSSE SEARCHRESULT : \(totalExpenseSearchResults)")
    }
    
    
}
