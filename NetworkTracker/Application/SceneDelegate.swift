//
//  SceneDelegate.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 11.07.2024.
//

import UIKit
import NetworkExtension
import AppTrackingTransparency
import AdSupport

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
//    var attStatus: ATTrackingManager.AuthorizationStatus? {
//        didSet {
//            guard oldValue != attStatus else { return }
//            if attStatus == .authorized {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    self.configureFilter()
//                }
//            }
//        }
//    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let viewModel = MainScreenViewModel()
        let viewController = MainViewController(mainScreenViewModel: viewModel)
        let navController = UINavigationController(rootViewController: viewController)
        
        window.rootViewController = navController
        window.makeKeyAndVisible()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        NotificationCenter.default.post(name: Constants.ObservableNotification.appBecameActive.name, object: nil)
//        makeATT()
    }
    
//    func configureFilter() {
//        NEFilterManager.shared().loadFromPreferences { (error) in
//            switch error {
//            case .none:
//                if NEFilterManager.shared().providerConfiguration == nil {
//                    let newConfiguration = NEFilterProviderConfiguration()
//                    newConfiguration.filterBrowsers = true
//                    newConfiguration.username = "UserName"
//                    newConfiguration.organization = "NT"
//                    NEFilterManager.shared().providerConfiguration = newConfiguration
//                }
//                
//                NEFilterManager.shared().isEnabled = true
//                NEFilterManager.shared().saveToPreferences { error in
//                    if let saveError = error {
//                        print("Failed to save the filter configuration: \(saveError)")
//                    }
//                }
//            case .some(let error):
//                print("Failed to load the filter configuration: \(error)")
//            }
//        }
//    }
    
//    func makeATT() {
//        
//        ATTrackingManager.requestTrackingAuthorization { status in
//            self.attStatus = status
//            
//            switch status {
//            case .authorized:
//                print("Authorized")
//            case .denied:
//                print("Denied")
//            case .notDetermined:
//                print("Not Determined")
//                Task {
//                    await MainActor.run {
//                        self.makeATT()
//                    }
//                }
//            case .restricted:
//                print("Restricted")
//            @unknown default:
//                print("Unknown")
//            }
//        }
//    }
}

