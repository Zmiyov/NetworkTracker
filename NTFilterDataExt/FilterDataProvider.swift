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
        os_log("FilterDataProvider init", log: log)
        super.init()
    }

    override func startFilter(completionHandler: @escaping (Error?) -> Void) {
        os_log("FilterDataProvider start", log: log)
        completionHandler(nil)
    }
    
    override func stopFilter(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    override func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        return .needRules()
//        return .allow()
    }
}
