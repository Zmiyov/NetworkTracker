//
//  NSManagedObjectContext+Combine.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 11.07.2024.
//

import CoreData
import Combine

extension NSManagedObjectContext {
    func fetchPublisher<T: NSFetchRequestResult>(for fetchRequest: NSFetchRequest<T>) -> AnyPublisher<[T], Error> {
        Future { promise in
            self.perform {
                do {
                    let result = try self.fetch(fetchRequest)
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
