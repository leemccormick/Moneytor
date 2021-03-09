//
//  AppDelegate.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) { (userDidAllow, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
            
            if userDidAllow {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        
        settingUpDefaultsCategories()
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - 3 Fuctions for RemoteNotifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        IncomeController.shared.subscribeForRomoteNotifications { (success) in
            if success {
                print("We successfully signed up for remote notifiactions.")
            } else {
                print("We failed to sign up for remote notifications.")
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
        print(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        IncomeController.shared.fetchAllIncomes()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    func settingUpDefaultsCategories() {
        ExpenseCategoryController.shared.fetchAllExpenseCategories()
        if ExpenseCategoryController.shared.expenseCategories.isEmpty {
            let expenseDefaultCategories = [
                ExpenseCategory(name: "_other", emoji: "💸", id: "1F1EFA62-7ED2-4325-8A52-210B14384BCB", expenses: nil),
                ExpenseCategory(name: "food", emoji: "🍔", id: "598DEBF2-E017-4536-AF32-E9BEDF0A3D81", expenses: nil),
                ExpenseCategory(name: "utility", emoji: "📞", id: "EFD4377B-161B-4563-A312-F7013BE7E0F7", expenses: nil),
                ExpenseCategory(name: "health", emoji: "💪",  id: "EF566A40-6A34-477F-BCDD-71FB9CBA8CED", expenses: nil),
                ExpenseCategory(name: "grocery", emoji: "🛒",  id: "0E435DAB-E1E0-43FF-84B6-5B14BF18C541", expenses: nil),
                ExpenseCategory(name: "shopping", emoji: "🛍",  id: "162E5287-35CA-4DDC-BE58-1784534FBA70", expenses: nil),
                ExpenseCategory(name: "entertainment", emoji: "🎬",  id: "36FE22EE-A735-4612-BFED-C4587FA8CD62", expenses: nil),
                ExpenseCategory(name: "transportation", emoji: "🚘",  id: "D6424512-7973-4F7F-A9E2-01D32271A7C9", expenses: nil)
            ]
            
            let sortedCategories = expenseDefaultCategories.sorted{$0.name?.lowercased() ?? "" < ($1.name?.lowercased()) ?? ""}
            ExpenseCategoryController.shared.expenseCategories.append(contentsOf: sortedCategories)
        }
        
        IncomeCategoryController.shared.fetchAllIncomeCategories()
        if IncomeCategoryController.shared.incomeCategories.isEmpty {
            let incomeDefaultCategories: [IncomeCategory] = [
                IncomeCategory(name: "_other", emoji: "💵", incomes: nil, id: "E46573D3-C3C3-48B0-99F5-1DF6B1D8FFF1"),
                IncomeCategory(name: "salary", emoji: "💳", incomes: nil, id: "A5577198-7298-4E8A-BBDC-6CFA07BB4271"),
                IncomeCategory(name: "saving account", emoji: "💰", incomes: nil, id: "961F3F7E-E03E-4D26-B36C-B7928466F403"),
                IncomeCategory(name: "checking account", emoji: "🏧", incomes: nil, id: "9758F6A5-90F4-454A-8B8E-DFF6E6379AC0")
            ]
            let sortedCategories = incomeDefaultCategories.sorted{$0.name?.lowercased() ?? "" < ($1.name?.lowercased()) ?? ""}
            IncomeCategoryController.shared.incomeCategories.append(contentsOf: sortedCategories)
        }
    }
}


