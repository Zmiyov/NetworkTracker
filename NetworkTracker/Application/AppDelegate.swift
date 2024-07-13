//
//  AppDelegate.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 11.07.2024.
//

import UIKit
import NetworkExtension

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        NEFilterManager.shared().isEnabled = false
    }
}
