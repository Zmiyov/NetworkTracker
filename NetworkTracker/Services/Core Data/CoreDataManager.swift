//
//  CoreDataManager.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 13.07.2024.
//

import CoreData
import Combine

/// Class that manage operations with Core Data
final class CoreDataManager {

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
    
    /// Obseves changes in database and post notification using NotificationCenter if they are
    private func observeChanges() {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: managedObjectContext)
            .sink {  _ in
                NotificationCenter.default.post(name: Constants.ObservableNotification.appBecameActive.name, object: nil)
            }
            .store(in: &cancellables)
    }
    
    /// Fetch all saved entities from Core Data
    /// - Returns: Array of RequestInfoEntity
    func fetchAll() throws -> [RequestInfoEntity] {
        var requests: [RequestInfoEntity] = []
        let request: NSFetchRequest<RequestInfoEntity> = RequestInfoEntity.fetchRequest()

        try performAndWait {
            requests = try self.managedObjectContext.fetch(request)
        }
        
        return requests
    }
    
    /// Add a new request to a database
    func addRequestToDatabase(requestText: String, requestDate: Date, websiteLink: String) throws {
        let context = self.managedObjectContext
        try performAndWait {
            let query = RequestInfoEntity(requestText: requestText, requestDate: requestDate, websiteLink: websiteLink, helper: context)
            print(query)
        }
        try saveContext(context: context)
    }
    
    /// Delete a certain request from a database
    func delete(request: RequestInfoEntity) throws  {
        let context = self.managedObjectContext
        try performAndWait {
            context.delete(request)
        }
        try saveContext(context: context)
    }
    
    /// Delete all requests from a database
    func deleteAllRequests() throws {
        let context = self.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RequestInfoEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try performAndWait {
            try context.execute(deleteRequest)
            try context.save()
        }
    }
    
    /// Fetch a certain request from a database
    func fetchRequest(withID id: String) throws -> RequestInfoEntity? {
        let allItems = try fetchAll()
        let filteredItem = allItems.filter { $0.id == id }.first
        return filteredItem
    }
    
    
    /// A private instance method that executes a given closure within the context of the managed object context, ensuring that any errors thrown by the closure are properly propagated.
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
    
    //MARK: - Core Data Saving
    /// A method that saves the managed object context
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
