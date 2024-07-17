//
//  NEFilterFlow+GetHost.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 16.07.2024.
//

import Foundation
import NetworkExtension

extension NEFilterFlow {
    
    /// Function retrieves the host from a URL or an appropriate identifier from a network flow.
    /// - Returns: Returns an optional String containing the host or identifier of the network flow.
    func getHost() -> String? {
        if let host = self.url?.host {
            return host
        }
        
        switch self {
        case let browserFlow as NEFilterBrowserFlow:
            return browserFlow.request?.url?.absoluteString
        case let socketFlow as NEFilterSocketFlow:
            var endpoint = "unknown"
            if let neEndpoint = socketFlow.remoteEndpoint {
                endpoint = "\(neEndpoint)"
            }

            return "socket: \(endpoint)"
        default:
            return nil
        }
    }
}
