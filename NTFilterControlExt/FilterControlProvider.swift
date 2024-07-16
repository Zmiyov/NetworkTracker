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
        
        if let url = flow.url {
            // Save the request details to Core Data
            do {
                try saveRequestToDatabase(request: url)
                completionHandler(.allow(withUpdateRules: true))
            } catch {
                completionHandler(.allow(withUpdateRules: false))
            }
           
        } else {
            completionHandler(.allow(withUpdateRules: false))
        }
    }
    
    private func saveRequestToDatabase(request: URL) throws {
        let query = request.absoluteString
        let link = request.host() ?? "No link"
        try CoreDataManager.shared.addRequest(requestText: query, requestDate: Date(), websiteLink: link)
    }
}
