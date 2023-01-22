//
//  MedInteractionsApp.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//

import SwiftUI

@main
struct MedInteractionsApp: App {
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(
                    \.managedObjectContext,
                              dataController.container.viewContext
                )
        }
    }
}
