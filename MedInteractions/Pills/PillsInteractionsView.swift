//
//  PillsInteractionsView.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//

import SwiftUI

struct PillsInteractionsView: View {
    @ObservedObject var viewModel: PillsInteractionsViewModel
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name)
    ]) var medication: FetchedResults<Medication>
    @State private var error = ""
    
    var body: some View {
        VStack {
            if viewModel.getInformationFromList().isEmpty
                && error.isEmpty
                && !medication.isEmpty,
               getNotFoundMedication().isEmpty {
                ProgressView()
                Spacer()
            } else if !error.isEmpty {
                List {
                    Text(error)
                        .padding([.top, .bottom], 3)
                        .font(.custom("OldStandardTT-Regular", size: 18))
                }
            } else {
                List {
                    Section(shouldAddSection() ? "We could not find" : "") {
                        ForEach(getNotFoundMedication(), id: \.self) { notFoundMed in
                            Text(notFoundMed.capitalizingFirstLetter())
                                .font(.custom("OldStandardTT-Regular", size: 18))
                        }
                    }
                    Section(viewModel.getInformationFromList().isEmpty ? "" :
                                "Interactions") {
                        ForEach(viewModel.getInformationFromList(), id: \.self) { value in
                            Text(value)
                                .font(.custom("OldStandardTT-Regular", size: 18))
                        }
                        .padding(.top, 3)
                    }
                }
            }
        }
        .onAppear {
            getNames()
        }
    }
    
    func shouldAddSection() -> Bool {
        if getNotFoundMedication().isEmpty {
            return false
        } else {
            return true
        }
    }
    
    func getNotFoundMedication() -> [String] {
        guard !medication.isEmpty else { return [] }
        var notFoundArray = [String]()
        for med in medication {
            if let rxcui = med.rxcui, rxcui.isEmpty {
                if let name = med.name {
                    notFoundArray.append(name)
                }
            }
        }
        return notFoundArray
    }
    
    func getNames() {
        guard !medication.isEmpty else { return }
        for med in medication {
            if let rxcui = med.rxcui {
                viewModel.rxcuiArray.append(rxcui)
            }
        }
        Task {
            await viewModel.getInteractions() { message in
                self.error = message
            }
        }
    }
}
