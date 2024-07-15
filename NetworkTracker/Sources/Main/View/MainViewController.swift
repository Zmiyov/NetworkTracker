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
        case queriesInfoListCell
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
                                forCellWithReuseIdentifier: MainScreenCellIdentifiers.queriesInfoListCell.rawValue)
        return collectionView
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, QueryInfoModel>!
    private var filteredItemsSnapshot: NSDiffableDataSourceSnapshot<Section, QueryInfoModel> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, QueryInfoModel>()
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
        loadItems()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.loadItems), name: Constants.ObservableNotification.appBecameActive.name, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Constants.ObservableNotification.appBecameActive.name, object: nil)
    }
    
    private func configureView() {
        title = "Queries"
        view.backgroundColor = .tertiarySystemBackground
        
        let barButtonImage = UIImage(systemName: "menubar.arrow.down.rectangle")?.withTintColor(.black).withRenderingMode(.alwaysOriginal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: barButtonImage, style: .plain, target: self, action: #selector(openSettings))
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
    }
    
    private func bindViewModel() {
        mainScreenViewModel.items
            .sink { completion in
                if case .failure(let error) = completion {
                    print(error)
                }
            } receiveValue: { [weak self] infoModelsArray in
                self?.updateCollectionView(with: infoModelsArray)
            }
            .store(in: &cancellables)
    }
    
    @objc
    private func loadItems() {
        do {
            try mainScreenViewModel.getAllItems()
        } catch {
            showWarning(title: "Error", body: "Fetching error")
        }
    }
    
    @objc
    private func openSettings() {
        let settingsViewController = SettingsViewController()
        present(settingsViewController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension MainViewController {
    
    private func createDataSource() {
        dataSource = EmptyableDiffableDataSource<Section, QueryInfoModel>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, infoModel) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainScreenCellIdentifiers.queriesInfoListCell.rawValue, for: indexPath) as? InfoCollectionViewCell
            cell?.configure(with: infoModel)
            cell?.delegate = self
            return cell
        }, emptyStateView: EmptyView())
    }
    
    private func updateDataSource() {
        dataSource.apply(filteredItemsSnapshot)
    }
    
    private func updateCollectionView(with items: [QueryInfoModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, QueryInfoModel>()
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
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.width / 3)
    }
}

//MARK: - MyCollectionViewCellDelegate

extension MainViewController: MyCollectionViewCellDelegate {
    func didTapButton(in cell: InfoCollectionViewCell, id: String) {
        do {
            try mainScreenViewModel.deleteItem(with: id)
        } catch {
            showWarning(title: "Error", body: "Deleting error")
        }
        
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
