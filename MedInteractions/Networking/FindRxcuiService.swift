//
//  FindRxcuiService.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//

import Foundation

class FindRxcuiService: ObservableObject {
    var normResponse: NormResponse?
    
    func findRxcui(medication: String, callback: @escaping (String?) -> Void) async {
        guard !medication.isEmpty else { return }
        let joinedMedication = medication.replacingOccurrences(of: " ", with: "")
        
        guard let url = URL(string: "https://rxnav.nlm.nih.gov/REST/rxcui.json?name=\(joinedMedication)&search=1") else { fatalError("Missing URL") }

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
                        let decodedRxcui = try JSONDecoder().decode(NormResponse.self, from: data)
                        self.normResponse = decodedRxcui
                        let result = decodedRxcui.idGroup.rxnormId.first
                        callback(result)
                    } catch let error {
                        callback(nil)
                        print("Error decoding: ", error)
                    }
                }
            }
        }
        dataTask.resume()
    }
}

