//
//  MainViewModel.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 11.07.2024.
//


import Foundation
import Combine
import CoreData
import NetworkExtension

protocol MainScreenViewModelProtocol {
    var items: PassthroughSubject<[QueryInfoModel], Never> { get }
    var error: PassthroughSubject<(String, String), Never> { get }
    
    func getAllItems() throws
    func deleteItem(with id: String) throws
    func deleteAllItems() throws
    func filterServiceStatus() -> Bool
    func checkFilterService(completion: @escaping () -> Void)
}

final class MainScreenViewModel: MainScreenViewModelProtocol, ObservableObject {

    private(set) var items = PassthroughSubject<[QueryInfoModel], Never>()
    private(set) var error = PassthroughSubject<(String, String), Never>()
    private var cancellables: Set<AnyCancellable> = []
    
    init() {}

    func getAllItems() throws {
        let allRequests = try CoreDataManager.shared.fetchAll()
        allRequests.publisher
            .map { queryInfoEntity in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date = dateFormatter.string(from: queryInfoEntity.date ?? Date())
                let model = QueryInfoModel(id: queryInfoEntity.id ?? "", text: queryInfoEntity.text ?? "No query", date: date, url: queryInfoEntity.link)
                return model
            }
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.items.send(items)
            }
            .store(in: &cancellables)
    }
    
    func deleteItem(with id: String) throws {
        if let item = try CoreDataManager.shared.fetchItem(withID: id) {
            try CoreDataManager.shared.delete(request: item)
        }
    }
    
    func deleteAllItems() throws {
        try CoreDataManager.shared.deleteAllItems()
    }
    
    func filterServiceStatus() -> Bool {
        return NEFilterManager.shared().isEnabled
    }
    
    func checkFilterService(completion: @escaping () -> Void) {
        NEFilterManager.shared().loadFromPreferences { [weak self] error in
            guard let self else { return }
            if let loadError = error {
                self.error.send(("Error loading preferences", "\(loadError)"))
                completion()
                return
            }
            completion()
        }
    }
}
