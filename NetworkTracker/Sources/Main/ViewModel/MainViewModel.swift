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
    var items: PassthroughSubject<[RequestInfoModel], Never> { get }
    var error: PassthroughSubject<(String, String), Never> { get }
    
    func getAllRequests() throws
    func deleteRequest(with id: String) throws
    func deleteAllRequests() throws
    func filterServiceStatus() -> Bool
    func checkFilterService(completion: @escaping () -> Void)
}

final class MainScreenViewModel: MainScreenViewModelProtocol, ObservableObject {

    private(set) var items = PassthroughSubject<[RequestInfoModel], Never>()
    private(set) var error = PassthroughSubject<(String, String), Never>()
    private var cancellables: Set<AnyCancellable> = []
    
    init() {}
    
    /// A method that gets all entities from Core Data, maps them to a RequestInfoModel and sends them to a view using Combine
    func getAllRequests() throws {
        let allRequests = try CoreDataManager.shared.fetchAll()
        allRequests.publisher
            .map { queryInfoEntity in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date = dateFormatter.string(from: queryInfoEntity.date ?? Date())
                let model = RequestInfoModel(id: queryInfoEntity.id ?? "", text: queryInfoEntity.text ?? "No query", date: date, url: queryInfoEntity.link)
                return model
            }
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.items.send(items)
            }
            .store(in: &cancellables)
    }
    
    /// A method that deletes a certain entity from Core Data using its id
    func deleteRequest(with id: String) throws {
        if let item = try CoreDataManager.shared.fetchRequest(withID: id) {
            try CoreDataManager.shared.delete(request: item)
        }
    }
    
    /// A method that deletes all entities from Core Data
    func deleteAllRequests() throws {
        try CoreDataManager.shared.deleteAllRequests()
    }
    
    /// A method that checks filter service status and returns a bool value
    func filterServiceStatus() -> Bool {
        return NEFilterManager.shared().isEnabled
    }
    
    /// A method that loads NEFilterManager
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
