//
//  InteractionsFromListResponse.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//

import Foundation

struct InteractionsFromListResponse: Codable {
    var nlmDisclaimer: String
    var fullInteractionTypeGroup: [FullInteractionTypeGroup]
}

struct FullInteractionTypeGroup: Codable {
    var sourceDisclaimer: String
    var sourceName: String
    var fullInteractionType: [FullInteractionType]
}

struct FullInteractionType: Codable {
    var comment: String
    var minConcept: [MinConcept]
    var interactionPair: [InteractionPair]
}

struct MinConcept: Codable {
    var rxcui: String
    var name: String
    var tty: String
}
