//
//  NormResponse.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//

import Foundation

struct NormResponse: Codable {
    var idGroup: IdGroup
}

struct IdGroup: Codable {
    var rxnormId: [String]
}

