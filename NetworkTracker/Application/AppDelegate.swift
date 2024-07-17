//
//  AppDelegate.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 11.07.2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        
        ///Checking UNUserNotificationCenter autorization status
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                if settings.authorizationStatus == .authorized {
                    UNUserNotificationCenter.current().setNotificationCategories([Notifications.authorizeCategory])
                }
            }
        }
        return true
    }
    
    /// Requests authorization for UNUserNotificationCenter
    /// - Parameter completion: That is called once the authorization request is completed. It takes an optional Error parameter that contains any error encountered during the authorization process.
    func registerForNotifications(completion:@escaping ((Error?)->())) {
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().setNotificationCategories([Notifications.authorizeCategory])
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { (success, error) in
                if let err = error {
                    print("got error requesting push notifications: \(err)")
                    return
                }
                
                print("registered for push: \(success)")
                completion(error)
            })
        }
    }
}
