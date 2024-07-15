//
//  FilterDataProvider.swift
//  NTFilterDataExt
//
//  Created by Volodymyr Pysarenko on 12.07.2024.
//

import NetworkExtension
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
        return .allow()
    }
}
