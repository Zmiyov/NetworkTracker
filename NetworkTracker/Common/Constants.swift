//
//  Constants.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 15.07.2024.
//

import Foundation

struct Constants {
    static let appGroupIdentifier = "group.com.pysarenkodev.NetworkTracker"
    
    enum ObservableNotification {
        case appBecameActive
        case editAction
         
        var nameString:String {
            switch self {
            case .appBecameActive:
                return "app_became_active"
            case .editAction:
                return "edit_action"
            }
        }
        
        var name:NSNotification.Name {
            return NSNotification.Name(rawValue: nameString)
        }
    }
}
