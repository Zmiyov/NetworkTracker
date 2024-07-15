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
    
    override init() {
        os_log("FilterControlProvider init", log: log)
        super.init()
    }

    override func startFilter(completionHandler: @escaping (Error?) -> Void) {
        os_log("FilterControlProvider start", log: log)
        completionHandler(nil)
    }
    
    override func stopFilter(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        os_log("FilterControlProvider stop", log: log)
        completionHandler()
    }
    
    override func handleNewFlow(_ flow: NEFilterFlow, completionHandler: @escaping (NEFilterControlVerdict) -> Void) {
        if let url = flow.url,
            url.absoluteString.contains("google.com") 
        {
            // Save the request details to Core Data
            os_log("FilterControlProvider Handling new flow", log: log)
            
            do {
                os_log("FilterControlProvider save.", log: log)
                try saveRequestToDatabase(request: url)
                completionHandler(.allow(withUpdateRules: true))
            } catch {
                os_log("FilterControlProvider save request error.", log: log)
                completionHandler(.allow(withUpdateRules: false))
            }
           
        } else {
            os_log("FilterControlProvider No URL found in flow.", log: log)
            completionHandler(.allow(withUpdateRules: false))
        }
       
    }
    
    private func saveRequestToDatabase(request: URL) throws {
        let query = request.query ?? "No query"
        let link = request.host() ?? "No link"
        try CoreDataManager.shared.addRequest(requestText: query, requestDate: Date(), websiteLink: link)
        os_log("FilterControlProvider Saved request to database", log: log)
    }
}
