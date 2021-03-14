//
//  NotificationScheduler.swift
//  Moneytor
//
//  Created by Lee McCormick on 3/14/21.
//

import UserNotifications //Framework for using Notification
class NotificationScheduler {
    
    // MARK: - scheduleNotifications
    func scheduleNotifications(income: Income) {
        
        // guard this timeOfDay for the dateComponents
        guard let date = income.date,
              let id = income.id else { return }
        
        // this content for notification
        let content = UNMutableNotificationContent()
        content.title = "GETTING RICH!"
        content.body = "You are getting paid today from  \(income.incomeNameString) for \(income.incomeAmountString). " //using  nil coalescing when it nil.
        content.sound = .default //This Can change to any sound.
        
        // getting date component for trigger, only need [.hour,.minute] from medication.timeOfDay which we have to use guard on the top of this func
        let dateComponents = Calendar.current.dateComponents([.day,.month,.year,.minute,.hour], from: date)
        
        // using calendar
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // identifier for looking for it when we need to cancel or do something with it.
        let request = UNNotificationRequest(identifier: "\(id)", content: content, trigger: trigger)
        
        // Start WITH THIS LINE. AND WORK BACKWARD. TO FIND <#T##UNNotificationContent#> AND <#T##UNNotificationTrigger?#>
        //we need to add the notification that why need request ^
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Unable to add notification request: \(error.localizedDescription)")
            }
        }
    }
//______________________________________________________________________________________
    
    // When you delete medication, you need to cancel notification.
    func cancelNotification(income: Income) {
        
        guard let id = income.id else { return }
        
        // To remove the old notificatioin
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}

