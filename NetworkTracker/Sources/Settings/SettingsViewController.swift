//
//  SettingsViewController.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 15.07.2024.
//

import UIKit
import NetworkExtension


final class SettingsViewController: UIViewController {
    
    private let textLabel = UILabel(font: UIFont.systemFont(ofSize: 17, weight: .bold))
    
    private let enabledTrackingSwitch: UISwitch = {
        let toogle = UISwitch()
        toogle.translatesAutoresizingMaskIntoConstraints = false
        return toogle
    }()
    
    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 10
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupView()
        setupSwitch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NEFilterManager.shared().loadFromPreferences { error in
            if let loadError = error {
                self.enabledTrackingSwitch.isOn = false
                self.showWarning(title: "Error loading preferences", body: "\(loadError)")
                return
            }
            self.handleFilterState()
        }
    }
    
    private func setupView() {
        title = "Settings"
        view.backgroundColor = .white
        handleFilterState()
    }
    
    private func setupSwitch() {
        enabledTrackingSwitch.addTarget(self, action: #selector(enableToggled), for: .valueChanged)
    }
    
    private func handleFilterState() {
        self.enabledTrackingSwitch.isOn = NEFilterManager.shared().isEnabled
        self.textLabel.text = self.enabledTrackingSwitch.isOn ? "Filter state: ON" : "Filter state: Off"
    }
    
    @objc
    private func enableToggled() {
        enabledTrackingSwitch.isOn ? enable() : disable()
        handleFilterState()
    }
    
    private func enable() {
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
                self.showWarning(title: "Error Enabling Filter", body: "\(err)")
            }
        }
    }
    
    private func disable() {
        NEFilterManager.shared().isEnabled = false
        NEFilterManager.shared().saveToPreferences { error in
            if let err = error {
                self.showWarning(title: "Error Disabling Filter", body: "\(err)")
            }
        }
    }

    private func setupConstraints() {
        
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)
        ])
        
        stack.addArrangedSubview(textLabel)
        stack.addArrangedSubview(enabledTrackingSwitch)
    }
}
