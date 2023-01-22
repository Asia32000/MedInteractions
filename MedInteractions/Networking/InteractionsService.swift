//
//  InteractionsService.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//

import Foundation

class InteractionsService: ObservableObject {
    var interactions: InteractionsResponse?
    
    func getInteractions(rxcui: Int, callback: @escaping (InteractionsResponse) -> Void) async {
        guard let url = URL(string: "https://rxnav.nlm.nih.gov/REST/interaction/interaction.json?rxcui=\(rxcui)&sources=DrugBank") else { fatalError("Missing URL") }
        
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
                        let decodedInteractions = try JSONDecoder()
                            .decode(InteractionsResponse.self, from: data)
                        self.interactions = decodedInteractions
                        callback(decodedInteractions)
                    } catch let error {
                        print("Error decoding: ", error)
                    }
                }
            }
        }
        dataTask.resume()
    }
}

