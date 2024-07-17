//
//  FilterControlProvider.swift
//  NTFilterControlExt
//
//  Created by Volodymyr Pysarenko on 14.07.2024.
//

import NetworkExtension
import OSLog
import UserNotifications

class FilterControlProvider: NEFilterControlProvider {
    
    private let log = OSLog(subsystem: "com.pysarenkodev.NTFilterControlExt", category: "general")

    override func startFilter(completionHandler: @escaping (Error?) -> Void) {
        os_log("FilterControlProvider start", log: log)
        completionHandler(nil)
    }
    
    override func stopFilter(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    override func handleNewFlow(_ flow: NEFilterFlow, completionHandler: @escaping (NEFilterControlVerdict) -> Void) {
        
        guard  let app = flow.sourceAppIdentifier
        else {
            completionHandler(.allow(withUpdateRules: false))
            return
        }
        
        guard let host = flow.getHost(), let url = flow.url else {
            completionHandler(.allow(withUpdateRules: false))
            return
        }
        
        /// Save the request details to Core Data and show it in notification
        do {
            fireNotification(app: app, hostname: host)
            try saveRequestToDatabase(request: url)
            completionHandler(.allow(withUpdateRules: true))
        } catch {
            fireErrorNotification(error: "\(error)")
            completionHandler(.allow(withUpdateRules: false))
        }
    }
    
    private func saveRequestToDatabase(request: URL) throws {
        let query = request.absoluteString
        let link = request.host() ?? "No link"
        try CoreDataManager.shared.addRequest(requestText: query, requestDate: Date(), websiteLink: link)
    }
    
    func fireNotification(app: String, hostname: String) {

        UNUserNotificationCenter.current().getDeliveredNotifications { notes in
            let content = UNMutableNotificationContent()
            content.categoryIdentifier = Constants.notificationCategory
            content.userInfo = ["app": app, "host": hostname]
            content.body = app
            content.title = hostname
            content.threadIdentifier = app
            
            let id = UUID().uuidString
            
            let note = UNNotificationRequest(identifier: id,
                                             content: content,
                                             trigger: nil)
            
            
            UNUserNotificationCenter.current().add(note) { (err) in
                if err != nil {
                    print("err: \(err!)")
                }
            }
        }
    }
    
    func fireErrorNotification(error: String) {
 
        let content = UNMutableNotificationContent()
        content.title = "Error Showing Request"
        content.body = error
    
        let note = UNNotificationRequest(identifier: "network_tracker_error_\(Date().timeIntervalSinceNow)",
                                         content: content,
                                         trigger: nil)
        
        UNUserNotificationCenter.current().add(note) { (err) in
            if err != nil {
                print("err: \(err!)")
            }
        }
    }
}
