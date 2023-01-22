//
//  DataController.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "MedInteractionsModel")

    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
