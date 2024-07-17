//
//  SettingsViewModel.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 16.07.2024.
//

import UIKit
import NetworkExtension
import UserNotifications
import Combine

protocol SettingsViewModelProtocol {
    var enabledFilterSwitch: CurrentValueSubject<Bool, Never> { get }
    var enabledPushSwitch: CurrentValueSubject<Bool, Never> { get }
    var error: PassthroughSubject<(String, String), Never> { get }
    
    func checkServices()
    func enableFilter()
    func disableFilter()
    func enablePush()
    func openSystemSettings()
}

final class SettingsViewModel: SettingsViewModelProtocol, ObservableObject {
    
    private(set) var enabledFilterSwitch = CurrentValueSubject<Bool, Never>(false)
    private(set) var enabledPushSwitch = CurrentValueSubject<Bool, Never>(false)
    private(set) var error = PassthroughSubject<(String, String), Never>()
    
    func checkServices() {
        NEFilterManager.shared().loadFromPreferences { error in
            if let loadError = error {
                self.enabledFilterSwitch.send(false)
                self.error.send(("Error loading preferences", "\(loadError)"))
                return
            } else {
                let state = NEFilterManager.shared().isEnabled
                self.enabledFilterSwitch.send(state)
            }
            
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                if settings.authorizationStatus == .authorized {
                    DispatchQueue.main.async {
                        self.enabledPushSwitch.send(true)
                    }
                }
            }
        }
    }
    
    func enableFilter() {
        if NEFilterManager.shared().providerConfiguration == nil {
            let newConfiguration = NEFilterProviderConfiguration()
            newConfiguration.username = "NetworkTracker"
            newConfiguration.organization = "NetworkTracker App"
            newConfiguration.filterBrowsers = true
            newConfiguration.filterSockets = true
            NEFilterManager.shared().providerConfiguration = newConfiguration
        }

        NEFilterManager.shared().isEnabled = true
        NEFilterManager.shared().saveToPreferences { error in
            if let err = error {
                self.error.send(("Error Enabling Filter", "\(err)"))
            } else {
                let state = NEFilterManager.shared().isEnabled
                self.enabledFilterSwitch.send(state)
            }
        }
    }
    
    func disableFilter() {
        NEFilterManager.shared().isEnabled = false
        NEFilterManager.shared().saveToPreferences { error in
            if let err = error {
                self.error.send(("Error Disabling Filter", "\(err)"))
            } else {
                let state = NEFilterManager.shared().isEnabled
                self.enabledFilterSwitch.send(state)
            }
        }
    }
    
    func enablePush() {
        (UIApplication.shared.delegate as? AppDelegate)?.registerForNotifications(completion: { error in
            guard error == nil else {
                self.error.send(("Error Register For Notifications", "\(error!)"))
                return
            }
            
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                if settings.authorizationStatus == .authorized {
                    DispatchQueue.main.async {
                        self.enabledPushSwitch.send(true)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.enabledPushSwitch.send(false)
                        
                    }
                }
            }
        })
    }
    
    func openSystemSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)") // Prints true
            })
        }
    }
}
