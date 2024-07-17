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
}

/// Class that provides default notification category value
final class Notifications {
    /// UNNotificationCategory for notification authorization 
    static var authorizeCategory: UNNotificationCategory = {
        return UNNotificationCategory(identifier: Constants.notificationCategory,
                                      actions: [],
                                      intentIdentifiers: [],
                                      hiddenPreviewsBodyPlaceholder: "Incoming network request",
                                      options: .customDismissAction)
    }()
}

