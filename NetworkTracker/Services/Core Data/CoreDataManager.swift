//
//  CoreDataManager.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 13.07.2024.
//

import CoreData
import Combine

class CoreDataManager {

    private var cancellables: Set<AnyCancellable> = []
    
    static let shared = CoreDataManager()
    
    private init() {
        observeChanges()
    }
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NetworkTracker")
        
        guard let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier) else {
            fatalError("Unable to find container URL for app group identifier")
        }
        
        let storeURL = appGroupURL.appendingPathComponent("qdata").appendingPathComponent("db.sqlite")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        
        storeDescription.shouldMigrateStoreAutomatically = true
        storeDescription.shouldInferMappingModelAutomatically = true
        
        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
    
    var managedObjectContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private func observeChanges() {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: managedObjectContext)
            .sink {  _ in
                NotificationCenter.default.post(name: Constants.ObservableNotification.appBecameActive.name, object: nil)
            }
            .store(in: &cancellables)
    }
    
    func fetchAll() throws -> [QueryInfoEntity] {
        var requests: [QueryInfoEntity] = []
        let request: NSFetchRequest<QueryInfoEntity> = QueryInfoEntity.fetchRequest()

        try performAndWait {
            requests = try self.managedObjectContext.fetch(request)
        }
        
        return requests
    }

    func addRequest(requestText: String, requestDate: Date, websiteLink: String) throws {
        let context = self.managedObjectContext
        try performAndWait {
            let query = QueryInfoEntity(requestText: requestText, requestDate: requestDate, websiteLink: websiteLink, helper: context)
            print(query)
        }
        try saveContext(context: context)
    }
    
    func delete(request: QueryInfoEntity) throws  {
        let context = self.managedObjectContext
        try performAndWait {
            context.delete(request)
        }
        try saveContext(context: context)
    }
    
    func deleteAllItems() throws {
        let context = self.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueryInfoEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try performAndWait {
            try context.execute(deleteRequest)
            try context.save()
        }
    }
    
    func fetchItem(withID id: String) throws -> QueryInfoEntity? {
        let allItems = try fetchAll()
        let filteredItem = allItems.filter { $0.id == id }.first
        return filteredItem
    }
    
    //MARK: Internals
    private func performAndWait(fn:@escaping (() throws -> Void)) throws {
        var caughtError:Error?
        
        self.managedObjectContext.performAndWait {
            do {
                try fn()
            } catch {
                caughtError = error
            }
        }
        
        if let error = caughtError {
            throw error
        }
    }
    
    //MARK: - Core Data Saving/Roll back support
    func saveContext(context: NSManagedObjectContext) throws {
        var caughtError:Error?
        
        context.performAndWait {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    caughtError = error
                }
            }
        }
        
        if let error = caughtError {
            print(error)
            throw error
        }
    }
}
