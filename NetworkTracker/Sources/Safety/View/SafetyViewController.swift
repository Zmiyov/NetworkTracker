//
//  SafetyViewController.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 17.07.2024.
//

import UIKit
import LocalAuthentication
import Combine

/// Class for checking rights of access for a user
final class SafetyViewController: UIViewController {
    
    /// Constants for adjusting interface parameters
    /// - Parameters:
    ///   - fontSize: Labels font size
    ///   - verticalSpacing: space between rows
    private enum Constants {
        static let fontSize: CGFloat = 17
        static let verticalSpacing: CGFloat = 20
    }
    
    private let faceIdImage: UIImageView = {
        var image = UIImageView()
        image.image = UIImage(named: "faceId")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
        
    private let activateFaceIdButton: UIButton = {
        var button = UIButton()
        button.setTitle("Tap to enter", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let verticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = Constants.verticalSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    var safetyScreenViewModel: SafetyViewModelProtocol
    
    private var cancellables: Set<AnyCancellable> = []
        
    init(safetyScreenViewModel: SafetyViewModelProtocol) {
        self.safetyScreenViewModel = safetyScreenViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupButton()
        bindViewModel()
        setupConstraints()
    }
    
    private func setupView() {
        view.backgroundColor = .white
    }
    
    private func setupButton() {
        let action = UIAction { [weak self] action in
            guard let self else { return }
            /// Call to check FaceID
            safetyScreenViewModel.authenticateTapped()
        }
        activateFaceIdButton.addAction(action, for: .touchUpInside)
    }
    
    ///Binding viewmodel to view using Combine
    private func bindViewModel() {
        safetyScreenViewModel.recognitionError
            .receive(on: RunLoop.main)
            .sink { [weak self] (title, body) in
                self?.showWarning(title: title, body: body)
            }
            .store(in: &cancellables)
        
        safetyScreenViewModel.accessError
            .receive(on: RunLoop.main)
            .sink { [weak self] (title, body) in
                self?.showAlertWithAction(title: title, body: body, actionButtonTitle: "Settings", actionBlock:  {
                    self?.safetyScreenViewModel.openSystemSettings()
                })
            }
            .store(in: &cancellables)
    }
    
    private func setupConstraints() {

        enum ConstraintConstants {
            static let horizontalInsets: CGFloat = 15
            static let verticalInsets: CGFloat = 20
        }
        
        view.addSubview(verticalStack)
        NSLayoutConstraint.activate([
            verticalStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ConstraintConstants.horizontalInsets),
            verticalStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ConstraintConstants.horizontalInsets),
            verticalStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        verticalStack.addArrangedSubview(faceIdImage)
        NSLayoutConstraint.activate([
            faceIdImage.widthAnchor.constraint(equalToConstant: 80),
            faceIdImage.heightAnchor.constraint(equalToConstant: 80)
        ])
        verticalStack.addArrangedSubview(activateFaceIdButton)
    }
}
