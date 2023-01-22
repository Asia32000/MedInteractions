//
//  InteractionsViewModel.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//

import Foundation
import SwiftUI

class InteractionsViewModel: ObservableObject {
    @ObservedObject var findRxcui = FindRxcuiService()
    @ObservedObject var interactions = InteractionsService()
    @ObservedObject var interactionsFromList = InteractionsFromListService()
    @Published var drugName = ""
    @Published var rxcui = ""
    @Published var interactionsResponse: InteractionsResponse?
    
    @Published var firstDrugName = ""
    @Published var secondDrugName = ""
    @Published var firstRxcui = ""
    @Published var secondRxcui = ""
    @Published var interactionsFromListResponse: InteractionsFromListResponse?
    
    @Published var interactionsArray = [String]()
    @Published var displayedInteractionsArray = [String]()
    @Published var getTenCount = 0
    
    @Published var rxcuiError = ""
    @Published var wasTapped = false
    
    let items = ["Single medication", "Two medications"]
    
    init() {
        
    }
    
    func getInteractions(callback: @escaping (String?) -> Void) {
        Task {
            await findRxcui.findRxcui(medication: drugName) { rxcui in
                if let stringRxcui = rxcui, let intRxcui = Int(stringRxcui) {
                    self.rxcui = stringRxcui
                    Task {
                        await self.interactions.getInteractions(rxcui: intRxcui) { interactions in
                            self.interactionsResponse = interactions
                            self.getInformation()
                            self.getTenMoreInteractions()
                        }
                    }
                } else {
                    callback("We could not find this medication")
                }
            }
        }
    }
    
    func getInteractionsFromTwoMedications(callback: @escaping (String?) -> Void) {
        Task {
            await findRxcui.findRxcui(medication: firstDrugName) { rxcui in
                if let stringRxcui = rxcui {
                    self.firstRxcui = stringRxcui
                    Task {
                        await self.findRxcui.findRxcui(medication: self.secondDrugName) { rxcui in
                            if let secondRxcuiString = rxcui {
                                self.secondRxcui = secondRxcuiString
                                Task {
                                    await self.interactionsFromList.getInteractionsFromList(medicationsRxcuis: [String(self.firstRxcui), String(self.secondRxcui)]) { interactions in
                                        if let interactions = interactions {
                                            self.interactionsFromListResponse = interactions
                                        } else {
                                            callback("There are no interactions or we could not find them.")
                                        }
                                    }
                                }
                            } else {
                                callback("We could not find this medication")
                            }
                        }
                    }
                } else {
                    callback("We could not find this medication")
                }
            }
        }
    }
    
    func getInformation() {
        guard (interactionsResponse != nil) else { return }
        for interactionGroup in interactionsResponse!.interactionTypeGroup {
            for interactionType in interactionGroup.interactionType {
                for interactionPair in interactionType.interactionPair {
                    interactionsArray.append(interactionPair.description)
                }
            }
        }
    }
    
    func getTenMoreInteractions() {
        displayedInteractionsArray += interactionsArray[..<10]
        interactionsArray.removeFirst(10)
    }
    
    func getInformationFromTwoMedications() -> String? {
        guard (interactionsFromListResponse != nil) else { return nil }
        for interactionGroup in interactionsFromListResponse!.fullInteractionTypeGroup {
            for interactionType in interactionGroup.fullInteractionType {
                for interactionPair in interactionType.interactionPair {
                    return interactionPair.description
                }
            }
        }
        return nil
    }
    
    func clearInteractions() {
        interactionsResponse = nil
        wasTapped = true
        rxcuiError = ""
        displayedInteractionsArray = []
        interactionsArray = []
        getTenCount = 0
    }
    
    func shouldShowProgressView() -> Bool {
        if wasTapped && rxcuiError.isEmpty && interactionsArray.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    func shouldDisableButton() -> Bool {
        if firstDrugName.isEmpty || secondDrugName.isEmpty {
            return true
        } else {
            return false
        }
    }
}
