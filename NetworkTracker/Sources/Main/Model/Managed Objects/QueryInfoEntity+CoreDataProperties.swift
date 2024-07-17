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
    
    @NSManaged public var id: String?
    @NSManaged public var date: Date?
    @NSManaged public var link: String?
    @NSManaged public var text: String?

}

extension QueryInfoEntity : Identifiable {

}

extension QueryInfoEntity {
    convenience init(requestText: String, requestDate: Date, websiteLink: String, helper context:NSManagedObjectContext) {
        self.init(helper: context)
        
        self.id = UUID().uuidString
        self.text = requestText
        self.date = requestDate
        self.link = websiteLink
    }
    
    convenience init(helper context: NSManagedObjectContext) {
        self.init(entity: NSEntityDescription.entity(forEntityName: "QueryInfoEntity", in: context)!, insertInto: context)
    }
}
