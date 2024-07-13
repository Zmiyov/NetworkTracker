//
//  FilterDataProvider.swift
//  NTFilterDataExt
//
//  Created by Volodymyr Pysarenko on 12.07.2024.
//

import NetworkExtension
//import CoreData
import OSLog

class FilterDataProvider: NEFilterDataProvider {
    
    private let log = OSLog(subsystem: "com.pysarenkodev.NTFilterDataExt", category: "general")
    
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
            saveRequestToDatabase(request: url)
            return .allow()
        } else {
            os_log("No URL found in flow.", log: log)
            return .allow()
        }
    }
    
    private func saveRequestToDatabase(request: URL) {
        let query = request.query ?? "No query"
        let link = request.absoluteString
        CoreDataManager.shared.addRequest(requestText: query, requestDate: Date(), websiteLink: link)
        os_log("Saved request to database", log: log)
    }

}
