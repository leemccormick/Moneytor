//
//  NotificationScheduler.swift
//  Moneytor
//
//  Created by Lee McCormick on 3/14/21.
//

import UserNotifications

class NotificationScheduler {    
    // MARK: - scheduleNotifications For Income
    func scheduleIncomeNotifications(income: Income) {
        guard let date = income.date,
              let id = income.id else { return }
        let content = UNMutableNotificationContent()
        content.title = "GETTING RICH!"
        content.body = "You are getting paid today from  \(income.incomeNameString) for \(income.incomeAmountString). "
        content.sound = .default
        
        let dateComponents = Calendar.current.dateComponents([.day,.month,.year], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "\(id)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Unable to add notification request: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelIncomeNotification(income: Income) {
        guard let id = income.id else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    // MARK: - scheduleNotifications For Expense
    func scheduleExpenseNotifications(expense: Expense) {
        guard let date = expense.date,
              let id = expense.id else { return }
        let content = UNMutableNotificationContent()
        content.title = "A BILL NEEDED TO BE PAID!"
        content.body = "Today is the due date for  \(expense.expenseNameString) bill. Don't forget to take care of this bill which is cost \(expense.expenseAmountString). "
        content.sound = .default
        
        let dateComponents = Calendar.current.dateComponents([.day,.month,.year], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "\(id)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Unable to add notification request: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelExpenseNotification(expense: Expense) {
        guard let id = expense.id else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}

