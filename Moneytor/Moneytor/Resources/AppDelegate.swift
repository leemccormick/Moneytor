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
        if UserDefaults.standard.value(forKey: "baseCode") == nil {
            UserDefaults.standard.setValue("USD", forKey: "baseCode")
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (authorized, error) in
            if let error = error {
                print("There was an error requesting authorization to use notifications. Error: \(error.localizedDescription)")
            }
            
            if authorized {
                UNUserNotificationCenter.current().delegate = self
                print("✅ The user authorized notifications.")
            } else {
                print("❌ The user did not authorized notifications.")
            }
        }
        
        ExpenseCategoryController.shared.fetchAllExpenseCategories()
        IncomeCategoryController.shared.fetchAllIncomeCategories()
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
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
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification will present...")
        completionHandler([.sound, .banner])
    }
}
