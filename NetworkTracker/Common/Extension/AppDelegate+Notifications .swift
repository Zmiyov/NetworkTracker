//
//  AppDelegate+Notifications .swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 16.07.2024.
//

import Foundation
import UIKit
import UserNotifications

extension AppDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    func showEditController(for appIdentifier:String) {
        NotificationCenter.default.post(name: Constants.ObservableNotification.editAction.name, object: appIdentifier)
    }
    
    static func removeNotifications(for appIdentifier:String) {
        UNUserNotificationCenter.current().getDeliveredNotifications { notes in
            let ids = notes.filter { $0.request.content.threadIdentifier == appIdentifier }.map { $0.request.identifier }
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ids)
        }
    }
}
class Notifications {
    static var authorizeCategory:UNNotificationCategory = {
        return UNNotificationCategory(identifier: Constants.notificationCategory,
                                      actions: [],
                                      intentIdentifiers: [],
                                      hiddenPreviewsBodyPlaceholder: "Incoming network request",
                                      options: .customDismissAction)
    }()
}

