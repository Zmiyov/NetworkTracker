//
//  ViewController.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 11.07.2024.
//

import UIKit
import Combine
import NetworkExtension

final class MainViewController: UIViewController {
    
    private enum MainScreenCellIdentifiers: String {
        case requestInfoListCell
    }
    enum Section: CaseIterable {
        case main
    }
    
    var mainScreenViewModel: MainScreenViewModelProtocol
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.register(InfoCollectionViewCell.self,
                                forCellWithReuseIdentifier: MainScreenCellIdentifiers.requestInfoListCell.rawValue)
        return collectionView
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, RequestInfoModel>!
    private var filteredItemsSnapshot: NSDiffableDataSourceSnapshot<Section, RequestInfoModel> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, RequestInfoModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems([])
        return snapshot
    }
    
    private var cancellables: Set<AnyCancellable> = []
        
    init(mainScreenViewModel: MainScreenViewModelProtocol) {
        self.mainScreenViewModel = mainScreenViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setConstraints()
        configureCollectionView()
        bindViewModel()
        createDataSource()
        loadAllRequests()
        
        ///Observer that waits for notification when the app become active to reload items
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.loadAllRequests), name: Constants.ObservableNotification.appBecameActive.name, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ///Cheking state of filter service
        mainScreenViewModel.checkFilterService { [weak self] in
            guard let self else { return }
            checkIfServiceActive()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Constants.ObservableNotification.appBecameActive.name, object: nil)
    }
    
    private func configureView() {
        title = "Queries"
        view.backgroundColor = .tertiarySystemBackground
        
        let barButtonImage = UIImage(systemName: "gearshape")?.withTintColor(.black).withRenderingMode(.alwaysOriginal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: barButtonImage, style: .plain, target: self, action: #selector(openSettings))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear list", image: nil, target: self, action: #selector(clearList))
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
    }
    
    ///Binnding viewmodel to view using Combine
    private func bindViewModel() {
        mainScreenViewModel.items
            .receive(on: RunLoop.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print(error)
                }
            } receiveValue: { [weak self] infoModelsArray in
                self?.updateCollectionView(with: infoModelsArray)
            }
            .store(in: &cancellables)
        
        mainScreenViewModel.error
            .receive(on: RunLoop.main)
            .sink { [weak self] (title, body) in
                self?.showWarning(title: title, body: body)
            }
            .store(in: &cancellables)
    }
    
    @objc
    /// Loads all requests and shows alert with error description
    private func loadAllRequests() {
        do {
            try mainScreenViewModel.getAllRequests()
        } catch {
            showWarning(title: "Error", body: "Fetching error")
        }
    }
    
    @objc
    private func openSettings() {
        let settingsViewModel = SettingsViewModel()
        let settingsViewController = SettingsViewController(settingsViewModel: settingsViewModel)
        let navigationController = UINavigationController(rootViewController: settingsViewController)
        present(navigationController, animated: true)
    }
    
    @objc
    /// Shows alert with two options: cancel and delete all. Can throw an error if deleting is failed.
    private func clearList() {
        showAlertWithAction(title: "Delete All", body: "Do you want to delete all items?", actionButtonTitle: "Delete All", actionBlock:  { [weak self] in
            guard let self else { return }
            do {
                try mainScreenViewModel.deleteAllRequests()
            } catch {
                showWarning(title: "Error", body: "Deleting error")
            }
        })
  
    }
    
    /// Shows an alert that offer open settings if network filter is disabled
    private func checkIfServiceActive() {
        if mainScreenViewModel.filterServiceStatus() == false {
            showAlertWithAction(title: "Filter is disabled", body: "Change state in the settings", actionButtonTitle: "Settings", actionBlock:  { [weak self] in
                guard let self else { return }
                self.openSettings()
            })
        }
    }
}

// MARK: - UICollectionViewDataSource

extension MainViewController {
    
    private func createDataSource() {
        dataSource = EmptyableDiffableDataSource<Section, RequestInfoModel>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, infoModel) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainScreenCellIdentifiers.requestInfoListCell.rawValue, for: indexPath) as? InfoCollectionViewCell
            cell?.configureCell(with: infoModel)
            cell?.delegate = self
            return cell
        }, emptyStateView: EmptyView())
    }
    
    private func updateDataSource() {
        dataSource.apply(filteredItemsSnapshot)
    }
    
    private func updateCollectionView(with items: [RequestInfoModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, RequestInfoModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UICollectionViewDelegate

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.width / 2.5)
    }
}

//MARK: - MyCollectionViewCellDelegate

extension MainViewController: MyCollectionViewCellDelegate {
    /// Shows alert with two options: cancel and delete. Can throw an error if deleting is failed.
    func didTapDeleteButton(in cell: InfoCollectionViewCell, id: String) {
        showAlertWithAction(title: "Delete", body: "Do you want to delete the item?", actionButtonTitle: "Delete", actionBlock:  { [weak self] in
            guard let self else { return }
            do {
                try mainScreenViewModel.deleteRequest(with: id)
            } catch {
                showWarning(title: "Error", body: "Deleting error")
            }
        })
    }
}

// MARK: - Set Constraints

extension MainViewController {
    private func setConstraints() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
}
