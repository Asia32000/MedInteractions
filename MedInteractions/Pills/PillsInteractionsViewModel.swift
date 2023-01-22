//
//  PillsInteractionsViewModel.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//

import Foundation
import SwiftUI

class PillsInteractionsViewModel: ObservableObject {
    @ObservedObject var findRxcuiService = FindRxcuiService()
    @ObservedObject var interactionsService = InteractionsFromListService()
    @Published var rxcuiArray = [String]()
    @Published var interactionsFromListResponse: InteractionsFromListResponse?
    
    init() {
        
    }
    
    func getInteractions(callback: @escaping (String) -> Void) async {
        guard !rxcuiArray.isEmpty else { return }
        await interactionsService.getInteractionsFromList(medicationsRxcuis: rxcuiArray) { interactions in
            if let interactions = interactions {
                self.interactionsFromListResponse = interactions
            } else {
                callback("There are no interactions or we could not find them.")
            }
        }
    }
    
    func getInformationFromList() -> [String] {
        var interactionsArray = [String]()
        guard (interactionsFromListResponse != nil) else { return [] }
        for interactionGroup in interactionsFromListResponse!.fullInteractionTypeGroup {
            for interactionType in interactionGroup.fullInteractionType {
                for interactionPair in interactionType.interactionPair {
                    interactionsArray.append(interactionPair.description)
                }
            }
        }
        return interactionsArray
    }
}
