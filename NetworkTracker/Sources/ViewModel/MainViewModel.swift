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
    
    func fetchItemsFromCoreData()
    func deleteItem(with id: UUID)
}

final class MainScreenViewModel: MainScreenViewModelProtocol, ObservableObject {
    
    let items = PassthroughSubject<[QueryInfoModel], Never>()
    private var cancellables: Set<AnyCancellable> = []
    
    private let context = CoreDataManager.shared.context
    
    init() {
        observeChanges()
    }
    
    private func observeChanges() {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: context)
            .sink { [weak self] _ in
                self?.fetchItemsFromCoreData()
            }
            .store(in: &cancellables)
    }
    
    func fetchItemsFromCoreData() {
        let fetchRequest: NSFetchRequest<NetworkTracker.QueryInfoEntity> = QueryInfoEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        context.fetchPublisher(for: fetchRequest)
            .map { queryInfoEntities in
                queryInfoEntities.compactMap { queryInfoEntity in
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM-dd-yyyy"
                    let date = dateFormatter.string(from: queryInfoEntity.date ?? Date())
                    let model = QueryInfoModel(id: queryInfoEntity.id ?? UUID(), text: queryInfoEntity.text ?? "No query", date: date, url: queryInfoEntity.link)
                    return model
                }
            }
            .replaceError(with: [])
            .sink { [weak self] items in
                self?.items.send(items)
            }
            .store(in: &cancellables)
    }
    
    func deleteItem(with id: UUID) {
        if let item = fetchItem(withID: id) {
            CoreDataManager.shared.deleteRequest(item)
        }
    }
    
    func fetchItem(withID id: UUID) -> QueryInfoEntity? {
        let fetchRequest: NSFetchRequest<QueryInfoEntity> = QueryInfoEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1

        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Failed to fetch item: \(error)")
            return nil
        }
    }
}
