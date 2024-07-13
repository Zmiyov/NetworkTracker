//
//  QueryInfoEntity+CoreDataProperties.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 11.07.2024.
//
//

import Foundation
import CoreData


extension QueryInfoEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<QueryInfoEntity> {
        return NSFetchRequest<QueryInfoEntity>(entityName: "QueryInfoEntity")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var link: String?
    @NSManaged public var text: String?

}

extension QueryInfoEntity : Identifiable {

}
