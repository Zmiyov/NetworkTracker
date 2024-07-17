//
//  SafetyViewModel.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 17.07.2024.
//

import UIKit
import LocalAuthentication
import Combine

protocol SafetyViewModelProtocol {
    var recognitionError: PassthroughSubject<(String, String), Never> { get }
    var accessError: PassthroughSubject<(String, String), Never> { get }
    
    func authenticateTapped()
    func openSystemSettings()
}

final class SafetyViewModel: SafetyViewModelProtocol {
    
    private(set) var recognitionError = PassthroughSubject<(String, String), Never>()
    private(set) var accessError = PassthroughSubject<(String, String), Never>()
    
    init() {}
    
    /// Authenticates the user using biometrics and navigates to the main screen upon successful authentication or
    /// shows error in case problems with recognition or restricted access
    func authenticateTapped() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [weak self] success, authenticationError in
                guard let self else { return }
                
                DispatchQueue.main.async {
                    if success {
                        self.goToTheMainScreen()
                    } else {
                        ///error in case problems with recognition
                        self.recognitionError.send(("Authentication failed!", "Please try again."))
                    }
                }
            }
        } else {
            ///error in case restricted access
            self.accessError.send(("Authentication failed!", "Please turn on Face ID in Settings."))
        }
    }
    
    ///Opens main screen with animated transition.
    private func goToTheMainScreen() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first!.delegate as? SceneDelegate,
              let window = sceneDelegate.window else { return }
        
        let viewModel = MainScreenViewModel()
        let viewController = MainViewController(mainScreenViewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.isNavigationBarHidden = true
        window.rootViewController = navigationController
        
        let options: UIView.AnimationOptions = .transitionCrossDissolve
        let duration: TimeInterval = 0.3
        UIView.transition(with: window, duration: duration, options: options, animations: {})
    }
    
    ///Opens system settings for enabling Face ID
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
