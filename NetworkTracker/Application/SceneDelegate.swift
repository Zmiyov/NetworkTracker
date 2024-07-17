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
        requestATT()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    /// Requests authorization for AppTrackingTransparency
    func requestATT() {
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                print("Authorized")
            case .denied:
                print("Denied")
            case .notDetermined:
                print("Not Determined")
                Task {
                    await MainActor.run {
                        self.requestATT()
                    }
                }
            case .restricted:
                print("Restricted")
            @unknown default:
                print("Unknown")
            }
        }
    }
}

