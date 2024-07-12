//
//  AppProxyProvider.swift
//  NetworkTrackerNetworkExtension
//
//  Created by Volodymyr Pysarenko on 11.07.2024.
//

import CoreData
import NetworkExtension
import os.log

class AppProxyProvider: NEAppProxyProvider {
    
    private let log = OSLog(subsystem: "com.pysarenkodev.NetworkTrackerNetworkExtension", category: "general1")
    
    let coreDataStack = CoreDataStack.shared
    
    override func startProxy(options: [String : Any]? = nil, completionHandler: @escaping (Error?) -> Void) {
        os_log("Proxy start", log: log)
        completionHandler(nil)
    }
    
    override func stopProxy(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        os_log("Proxy stopped", log: log)
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
    }
    
    override func sleep(completionHandler: @escaping() -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
    }
    
    override func wake() {
        // Add code here to wake up.
    }
    
    override func handleNewFlow(_ flow: NEAppProxyFlow) -> Bool {
        os_log("New flow detected", log: OSLog.default, type: .info)
        if let tcpFlow = flow as? NEAppProxyTCPFlow {
            handleTCPFlow(tcpFlow)
            return true
        } else if let udpFlow = flow as? NEAppProxyUDPFlow {
            handleUDPFlow(udpFlow)
            return true
        }
        return false
    }
    
    func handleTCPFlow(_ tcpFlow: NEAppProxyTCPFlow) {
        tcpFlow.open(withLocalEndpoint: nil) { error in
            if let error = error {
                os_log("Failed to open TCP flow: %@", log: OSLog.default, type: .error, error.localizedDescription)
                return
            }
            os_log("TCP flow opened", log: OSLog.default, type: .info)
            self.readRequest(from: tcpFlow)
        }
    }
    
    func readRequest(from tcpFlow: NEAppProxyTCPFlow) {
        tcpFlow.readData { data, error in
            guard let data = data, error == nil else {
                if let error = error {
                    os_log("Failed to read data: %@", log: OSLog.default, type: .error, error.localizedDescription)
                }
                return
            }
            
            if let requestString = String(data: data, encoding: .utf8) {
                os_log("Request received: %@", log: OSLog.default, type: .info, requestString)
                if requestString.contains("google.com") {
                    self.saveRequestToDatabase(requestText: requestString, url: "https://google.com")
                }
            }
            
            // Continue reading data
            self.readRequest(from: tcpFlow)
        }
    }
    
    func saveRequestToDatabase(requestText: String, url: String) {
        let context = coreDataStack.context
        let newRequest = QueryInfoEntity(context: context)
        newRequest.date = Date()
        newRequest.text = requestText
        newRequest.link = url
        
        do {
            try context.save()
//            os_log("Request saved to database", log: OSLog.default, type: .info)
            os_log("Request saved to database", log: log)
        } catch {
//            os_log("Failed to save request: %@", log: OSLog.default, type: .error, error.localizedDescription)
            os_log("Failed to save request", log: log)
        }
    }
    
    func handleUDPFlow(_ udpFlow: NEAppProxyUDPFlow) {
        // Implement UDP flow handling if necessary
    }
}
