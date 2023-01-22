//
//  InteractionsResponse.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//

import Foundation

struct InteractionsResponse: Codable {
    var nlmDisclaimer: String
    var interactionTypeGroup: [InteractionTypeGroup]
}

struct InteractionTypeGroup: Codable {
    var sourceDisclaimer: String
    var sourceName: String
    var interactionType: [InteractionType]
}

struct InteractionType: Codable {
    var comment: String
    var minConceptItem: MinConceptItem
    var interactionPair: [InteractionPair]
}

struct MinConceptItem: Codable {
    var rxcui: String
    var name: String
    var tty: String
}

struct InteractionPair: Codable {
    var interactionConcept: [InteractionConcept]
    var severity: String
    var description: String
}

struct InteractionConcept: Codable {
    var minConceptItem: MinConceptItem
    var sourceConceptItem: SourceConceptItem
}

struct SourceConceptItem: Codable {
    var id: String
    var name: String
    var url: String
}

