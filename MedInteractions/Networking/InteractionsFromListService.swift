//
//  InteractionsFromListService.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//

import Foundation

class InteractionsFromListService: ObservableObject {
    
    func getInteractionsFromList(
            medicationsRxcuis: [String],
            interactions: @escaping (InteractionsFromListResponse?) -> Void
    ) async {
        guard !medicationsRxcuis.isEmpty else { return }
        
        let joinedRxcuis = medicationsRxcuis.joined(separator: "+")
        guard let url = URL(
            string: "https://rxnav.nlm.nih.gov/REST/interaction/list.json?rxcuis=\(joinedRxcuis)"
        )
            else {
                fatalError("Missing URL")
            }
        let urlRequest = URLRequest(url: url)

        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }
            guard let response = response as? HTTPURLResponse else { return }

            if response.statusCode == 200 {
                guard let data = data else { return }
                DispatchQueue.main.async {
                    do {
                        let decodedInteractionsFromList = try JSONDecoder()
                            .decode(InteractionsFromListResponse.self, from: data)
                        interactions(decodedInteractionsFromList)
                    } catch let error {
                        interactions(nil)
                        print("Error decoding: ", error)
                    }
                }
            }
        }
        dataTask.resume()
    }
}

