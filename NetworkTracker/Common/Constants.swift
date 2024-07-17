//
//  Constants.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 15.07.2024.
//

import Foundation

/// Struct that contains constants for the app
///   - Parameters:
///     - requestFilter: A String representing the domain to filter network requests
///     - appGroupIdentifier:  A String that used as a group identifier in the whole app
///     - notificationCategory: A String defining the notification category identifier
///     - pushActivityKey: A String key used for push activity notifications
struct Constants {
    static let requestFilter = "google.com"
    static let appGroupIdentifier = "group.com.pysarenkodev.NetworkTracker"
    static let notificationCategory = "network_request_category"
    static let pushActivityKey = "push_activity_key"
    
    /// Enum containing name for ObservableNotification that is used for tracking changes in Core Data
    enum ObservableNotification {
        case appBecameActive
         
        var nameString:String {
            switch self {
            case .appBecameActive:
                return "app_became_active"
            }
        }
        
        var name:NSNotification.Name {
            return NSNotification.Name(rawValue: nameString)
        }
    }
}
