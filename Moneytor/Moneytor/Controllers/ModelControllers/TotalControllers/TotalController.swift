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
    var totalBalanceMontly: Double = 0.0
    var totalIncomeMontly: Double = 0.0
    var totalExpenseMontly: Double = 0.0
    var totalBalanceString: String = "$00.00"
    var totalIncomeString: String = "$00.00"
    var totalExpenseString: String = "$00.00"
    var totalBalanceStringMontly: String = "$00.00"
    var totalIncomeStringMontly: String = "$00.00"
    var totalExpenseStringMontly: String = "$00.00"
    
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
    
    func calculateTotalIncomesBySpecificTime(startedTime: Date, endedTime: Date) {
        let incomes = IncomeController.shared.fetchIncomesFromTimePeriod(startedTime: startedTime, endedTime: endedTime)
        var sumIncome = 0.0
        for income in incomes {
            let incomeAmount = income.amount as? Double ?? 0.0
            sumIncome += incomeAmount
        }
        totalIncomeBySpecificTime = sumIncome
        totalIncomeBySpecificTimeString =  AmountFormatter.currencyInString(num: totalIncomeBySpecificTime)
    }
    
    func calculateTotalExpensesBySpecificTime(startedTime: Date, endedTime: Date) {
        let expenses = ExpenseController.shared.fetchExpensesFromTimePeriod(startedTime: startedTime, endedTime: endedTime)
        
        var sumExpenses = 0.0
        for expense in expenses {
            let expenseAmount = expense.amount as? Double ?? 0.0
            sumExpenses += expenseAmount
        }
        totalExpenseBySpecificTime = sumExpenses
        totalExpensesBySpecificTimeString =  AmountFormatter.currencyInString(num: totalExpenseBySpecificTime)
    }
    
    func calculateTotalBalanceBySpecificTime(startedTime: Date, endedTime: Date) {
        calculateTotalIncomesBySpecificTime(startedTime: startedTime, endedTime: endedTime)
        calculateTotalExpensesBySpecificTime(startedTime: startedTime, endedTime: endedTime)
        
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
        let incomes = IncomeCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: Date().startDateOfMonth, end: Date().endDateOfMonth)
        totalIncomeDict = IncomeCategoryController.shared.generateCategoryDictionaryByIncomesAndReturnDict(sections: incomes)
    }
    
    func generateTotalExpenseDictByMonthly(){
        let expenses = ExpenseCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: Date().startDateOfMonth, end: Date().endDateOfMonth)
        totalExpenseDictByMonthly = ExpenseCategoryController.shared.generateCategoryDictionaryByExpensesAndReturnDict(sections: expenses)
    }
    
    
    func generateTotalExpenseDictByTime(start: Date, end: Date) -> [Dictionary<String, Double>.Element] {
        let expenses = ExpenseCategoryController.shared.generateSectionsCategoiesByTimePeriod(start: start, end: end)
        
        let newTotalExpenseDict = ExpenseCategoryController.shared.generateCategoryDictionaryByExpensesAndReturnDict(sections: expenses)
        return newTotalExpenseDict
    }
    
    func calculateTotalIncomesByMonthly() {
        let incomes = IncomeController.shared.fetchIncomesFromTimePeriod(startedTime: Date().startDateOfMonth, endedTime: Date().endDateOfMonth)
        var sumIncome = 0.0
        for income in incomes {
            let incomeAmount = income.amount as? Double ?? 0.0
            sumIncome += incomeAmount
        }
        totalIncomeMontly = sumIncome
        totalIncomeStringMontly =  AmountFormatter.currencyInString(num: totalIncomeMontly)
    }
    
    func calculateTotalExpensesByMonthly() {
        let expenses = ExpenseController.shared.fetchExpensesFromTimePeriod(startedTime: Date().startDateOfMonth, endedTime: Date().endDateOfMonth)
        var sumExpenses = 0.0
        for expense in expenses {
            let expenseAmount = expense.amount as? Double ?? 0.0
            sumExpenses += expenseAmount
        }
        totalExpenseMontly = sumExpenses
        totalExpenseStringMontly =  AmountFormatter.currencyInString(num: totalExpenseMontly)
    }
    
    func calculateTotalBalanceByMonthly() {
        calculateTotalIncomesByMonthly()
        calculateTotalExpensesByMonthly()
        totalBalanceMontly = totalIncomeMontly - totalExpenseMontly
        totalBalanceStringMontly =  AmountFormatter.currencyInString(num: totalBalanceMontly)
    }
}
