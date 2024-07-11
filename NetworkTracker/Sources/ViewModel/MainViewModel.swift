//
//  MainViewModel.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 11.07.2024.
//


import Foundation
import Combine
import CoreData

protocol MainScreenViewModelProtocol {
    var items: PassthroughSubject<[QueryInfoModel], Never> { get }
    
    func fetchItems()
}

final class MainScreenViewModel: MainScreenViewModelProtocol, ObservableObject {
    private let mockData = [QueryInfoModel(text: "Query test", date: "March", url: "google.com"), 
                            QueryInfoModel(text: "Query test", date: "June", url: "google.com")]
    
    let items = PassthroughSubject<[QueryInfoModel], Never>()
    private var cancellables: Set<AnyCancellable> = []
    
    private let context = CoreDataStack.shared.context

    init() {}
    
    func fetchItems() {
        items.send(mockData)
    }
    
    func fetchItemsFromCoreData() {
        let fetchRequest: NSFetchRequest<NetworkTracker.QueryInfoEntity> = QueryInfoEntity.fetchRequest()
        
        context.fetchPublisher(for: fetchRequest)
            .map { queryInfoEntities in
                queryInfoEntities.compactMap { queryInfoEntity in
                    let dateFormatter = DateFormatter()
                    let date = dateFormatter.string(from: queryInfoEntity.date ?? Date())
                    let model = QueryInfoModel(text: queryInfoEntity.text ?? "", date: date, url: queryInfoEntity.link)
                    return model
                }
            }
            .replaceError(with: [])
            .sink { [weak self] items in
                self?.items.send(items)
            }
            .store(in: &cancellables)
    }
}
