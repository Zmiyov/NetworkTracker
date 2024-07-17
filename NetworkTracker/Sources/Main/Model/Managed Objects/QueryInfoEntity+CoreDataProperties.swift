//
//  RequestInfoEntity+CoreDataProperties.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 11.07.2024.
//
//

import Foundation
import CoreData


extension RequestInfoEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RequestInfoEntity> {
        return NSFetchRequest<RequestInfoEntity>(entityName: "RequestInfoEntity")
    }
    
    @NSManaged public var id: String?
    @NSManaged public var date: Date?
    @NSManaged public var link: String?
    @NSManaged public var text: String?

}

extension RequestInfoEntity : Identifiable {

}

extension RequestInfoEntity {
    /// Additional initializator for creating RequestInfoEntity
    convenience init(requestText: String, requestDate: Date, websiteLink: String, helper context:NSManagedObjectContext) {
        self.init(helper: context)
        
        self.id = UUID().uuidString
        self.text = requestText
        self.date = requestDate
        self.link = websiteLink
    }
    
    convenience init(helper context: NSManagedObjectContext) {
        self.init(entity: NSEntityDescription.entity(forEntityName: "RequestInfoEntity", in: context)!, insertInto: context)
    }
}
