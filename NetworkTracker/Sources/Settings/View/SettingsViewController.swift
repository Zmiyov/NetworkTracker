//
//  SettingsViewController.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 15.07.2024.
//

import UIKit
import NetworkExtension
import Combine

final class SettingsViewController: UIViewController {
    
    /// Constants for adjusting interface parameters
    /// - Parameters:
    ///   - fontSize: Labels font size
    ///   - verticalSpacing: space between rows
    private enum Constants {
        static let fontSize: CGFloat = 17
        static let verticalSpacing: CGFloat = 10
    }
    
    private let filterLabel = UILabel(font: UIFont.systemFont(ofSize: Constants.fontSize, weight: .bold))
    private let pushLabel = UILabel(font: UIFont.systemFont(ofSize: Constants.fontSize, weight: .bold))
    
    private let enabledFilterSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        switchControl.setContentCompressionResistancePriority(.required, for: .horizontal)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    private let enabledPushSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        switchControl.setContentCompressionResistancePriority(.required, for: .horizontal)
        return switchControl
    }()
    
    private let verticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = Constants.verticalSpacing
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let filterStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let pushStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    var settingsViewModel: SettingsViewModelProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(settingsViewModel: SettingsViewModelProtocol) {
        self.settingsViewModel = settingsViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupView()
        setupSwitches()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settingsViewModel.checkServices()
    }
    
    private func setupView() {
        title = "Settings"
        view.backgroundColor = .white
        /// Set initial state
        handleFilterState()
        handlePushState()
    }
    
    private func setupSwitches() {
        enabledFilterSwitch.addTarget(self, action: #selector(enableFilterToggled), for: .valueChanged)
        enabledPushSwitch.addTarget(self, action: #selector(enablePushToggled), for: .valueChanged)
    }
    
    private func handleFilterState(state: Bool = false) {
        enabledFilterSwitch.isOn = state
        filterLabel.text = enabledFilterSwitch.isOn ? "Filter state: ON" : "Filter state: Off"
    }
    
    private func handlePushState(state: Bool = false) {
        enabledPushSwitch.isOn = state
        pushLabel.text = state ? "Notifications state: ON" : "Notifications state: Off"
    }
    
    @objc
    /// Enables and disables network filter
    private func enableFilterToggled() {
        enabledFilterSwitch.isOn ? settingsViewModel.enableFilter() : settingsViewModel.disableFilter()
        handleFilterState()
    }
    
    @objc
    /// Enables and disables notifications. Opens system settings if needed.
    private func enablePushToggled() {
        if enabledPushSwitch.isOn == true {
            settingsViewModel.enablePush()
        } else {
            openSettings()
        }
    }
    
    /// Show an alert with an ability to open system settings
    private func openSettings() {
        showAlertWithAction(title: "Notifications are disabled", body: "Change state in the settings", actionButtonTitle: "Settings", then: { [weak self] in
            guard let self else { return }
            settingsViewModel.checkServices()
        }, actionBlock:  { [weak self] in
            guard let self else { return }
            settingsViewModel.openSystemSettings()
            dismiss(animated: false)
        })
    }
    
    /// Binds a view model to a view using Combine
    private func bindViewModel() {
        settingsViewModel.enabledFilterSwitch
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.handleFilterState(state: value)
            }
            .store(in: &cancellables)
        
        settingsViewModel.enabledPushSwitch
            .receive(on: RunLoop.main)
            .dropFirst()
            .sink { [weak self] value in
                self?.handlePushState(state: value)
                if value == false {
                    self?.openSettings()
                }
            }
            .store(in: &cancellables)
        
        settingsViewModel.error
            .receive(on: RunLoop.main)
            .sink { [weak self] (title, body) in
                self?.showWarning(title: title, body: body)
            }
            .store(in: &cancellables)
    }

    private func setupConstraints() {
        /// Constants for verticalStack constraints
        enum ConstraintConstants {
            static let horizontalInsets: CGFloat = 15
            static let verticalInsets: CGFloat = 20
        }
        
        view.addSubview(verticalStack)
        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: ConstraintConstants.verticalInsets),
            verticalStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ConstraintConstants.horizontalInsets),
            verticalStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ConstraintConstants.horizontalInsets)
        ])
        
        verticalStack.addArrangedSubview(filterStack)
        verticalStack.addArrangedSubview(pushStack)
        
        filterStack.addArrangedSubview(filterLabel)
        filterStack.addArrangedSubview(enabledFilterSwitch)

        pushStack.addArrangedSubview(pushLabel)
        pushStack.addArrangedSubview(enabledPushSwitch)
    }
}
