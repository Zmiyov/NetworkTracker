//
//  FilterDataProvider.swift
//  NTFilterDataExt
//
//  Created by Volodymyr Pysarenko on 12.07.2024.
//

import NetworkExtension
import CoreData
import OSLog

class FilterDataProvider: NEFilterDataProvider {
    
    private let log = OSLog(subsystem: "com.pysarenkodev.NTFilterDataExt", category: "general")
    
    let coreDataStack = CoreDataStack.shared
    
    override init() {
        os_log("Proxy init", log: log)
        super.init()
    }

    override func startFilter(completionHandler: @escaping (Error?) -> Void) {
        // Add code to initialize the filter.
        os_log("filter start", log: log)
        completionHandler(nil)
    }
    
    override func stopFilter(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code to clean up filter resources.
        completionHandler()
    }
    
    override func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        if let url = flow.url, url.absoluteString.contains("google.com") {
            // Save the request details to Core Data
            os_log("Handling new flow", log: log)
            saveRequest(url: url)
        } else {
            os_log("No URL found in flow.", log: log)
        }
        return .allow()
    }
    
    func saveRequest(url: URL) {
        // Extract the query from the URL
        let query = url.query ?? ""
        
        // Get the current date
        let currentDate = Date()
        os_log("Saving request", log: log)
        
        // Save to Core Data
        let context = coreDataStack.context
        let request = QueryInfoEntity(context: context)
        request.date = currentDate
        request.text = query
        request.link = url.absoluteString
        
        do {
            try context.save()
            os_log("Request saved successfully in filter.", log: log)
        } catch {
            os_log("Failed to save request in filter", log: log)
        }
    }
}
