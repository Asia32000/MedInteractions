//
//  Medication+CoreDataProperties.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//
//

import Foundation
import CoreData


extension Medication {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Medication> {
        return NSFetchRequest<Medication>(entityName: "Medication")
    }

    @NSManaged public var days: NSArray?
    @NSManaged public var dose: String?
    @NSManaged public var doseTime: NSArray?
    @NSManaged public var end: Date?
    @NSManaged public var frequency: Int16
    @NSManaged public var icon: String?
    @NSManaged public var id: UUID?
    @NSManaged public var isEndAdded: Bool
    @NSManaged public var name: String?
    @NSManaged public var notificationIdentifiers: NSArray?
    @NSManaged public var notifications: Bool
    @NSManaged public var pillsInStock: String?
    @NSManaged public var refillReminder: Bool
    @NSManaged public var reminder: Int16
    @NSManaged public var rxcui: String?
    @NSManaged public var start: Date?
    @NSManaged public var progress: NSManagedObject?

}

extension Medication : Identifiable {

}
