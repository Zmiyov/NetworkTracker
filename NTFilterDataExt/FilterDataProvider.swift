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

    override func startFilter(completionHandler: @escaping (Error?) -> Void) {
        os_log("FilterDataProvider start", log: log)
        completionHandler(nil)
    }
    
    override func stopFilter(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    override func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        if let url = flow.url,
               url.absoluteString.contains("google.com")
        {
            return .needRules()
        } else {
            return .allow()
        }
    }
}
