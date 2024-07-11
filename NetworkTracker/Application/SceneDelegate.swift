//
//  SceneDelegate.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 11.07.2024.
//

import UIKit

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

}

