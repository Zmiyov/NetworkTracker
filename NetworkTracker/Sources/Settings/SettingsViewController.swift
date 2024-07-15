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
            self.enabledTrackingSwitch.isOn = NEFilterManager.shared().isEnabled
        }
    }
    
    private func setupView() {
        view.backgroundColor = .white
        textLabel.text = "Filter state"
    }
    
    private func setupSwitch() {
        enabledTrackingSwitch.addTarget(self, action: #selector(enableToggled), for: .valueChanged)
    }
    
    @objc
    private func enableToggled() {
        enabledTrackingSwitch.isOn ? enable() : disable()
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
        view.addSubview(textLabel)
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15)
        ])
        
        view.addSubview(enabledTrackingSwitch)
        NSLayoutConstraint.activate([
            enabledTrackingSwitch.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            enabledTrackingSwitch.leadingAnchor.constraint(equalTo: textLabel.trailingAnchor, constant: 15),
            enabledTrackingSwitch.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            enabledTrackingSwitch.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
}
