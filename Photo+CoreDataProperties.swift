//
//  Photo+CoreDataProperties.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var data: Data?
    @NSManaged public var name: String?
    @NSManaged public var date: Date?

}

extension Photo : Identifiable {

}
