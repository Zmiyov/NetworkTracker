//
//  ViewController.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 11.07.2024.
//

import UIKit
import Combine

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
        mainScreenViewModel.fetchItems()
    }

    private func configureView() {
        title = "Queries"
        view.backgroundColor = .tertiarySystemBackground
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
    
    private func updateCollectionView(with items: [QueryInfoModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, QueryInfoModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UICollectionViewDataSource

extension MainViewController {
    
    func createDataSource() {
        dataSource = EmptyableDiffableDataSource<Section, QueryInfoModel>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, infoModel) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainScreenCellIdentifiers.queriesInfoListCell.rawValue, for: indexPath) as? InfoCollectionViewCell
            cell?.configure(with: infoModel)
            return cell
        }, emptyStateView: EmptyView())
    }
    
    func updateDataSource() {
        dataSource.apply(filteredItemsSnapshot)
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
