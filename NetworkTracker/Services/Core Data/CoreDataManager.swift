//
//  CoreDataManager.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 13.07.2024.
//

import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()

    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NetworkTracker")

        guard let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.pysarenkodev.NetworkTracker") else {
            fatalError("Unable to find app group container")
        }

        let storeURL = appGroupURL.appendingPathComponent("NetworkTracker.sqlite")
        let description = NSPersistentStoreDescription(url: storeURL)
        
        // Set migration options but avoid read-only option
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func addRequest(requestText: String, requestDate: Date, websiteLink: String) {
        let trackedRequest = QueryInfoEntity(context: context)
        trackedRequest.id = UUID()
        trackedRequest.text = requestText
        trackedRequest.date = requestDate
        trackedRequest.link = websiteLink
        saveContext()
    }

//    func fetchRequests() -> [QueryInfoEntity] {
//        let fetchRequest: NSFetchRequest<QueryInfoEntity> = QueryInfoEntity.fetchRequest()
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "requestDate", ascending: false)]
//        do {
//            return try context.fetch(fetchRequest)
//        } catch {
//            print("Failed to fetch requests: \(error)")
//            return []
//        }
//    }

    func deleteRequest(_ request: QueryInfoEntity) {
        context.delete(request)
        saveContext()
    }
}
