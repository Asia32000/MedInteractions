//
//  TwoMedicationsView.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//

import SwiftUI

struct TwoMedicationsView: View {
    @ObservedObject var viewModel: InteractionsViewModel
    @State private var error = ""
    @State private var wasTapped = false
    
    var body: some View {
        ScrollView {
            VStack {
                DrugInteractionsCheckerView()
                    .padding(.bottom, 36)
                
                Group {
                    TextField("Enter a first drug name", text: $viewModel.firstDrugName)
                        .withClearButton($viewModel.firstDrugName)
                        .padding(4)
                        .padding(.leading, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.darkPurple!, lineWidth: 1)
                        )
                        .padding(.bottom, 8)
                    TextField("Enter a second drug name", text: $viewModel.secondDrugName)
                        .withClearButton($viewModel.secondDrugName)
                        .padding(4)
                        .padding(.leading, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.darkPurple!, lineWidth: 1)
                        )
                }
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .onTapGesture {
                    hideKeyboard()
                }
                .padding([.trailing, .leading])
                
                Button {
                    hideKeyboard()
                    viewModel.interactionsResponse = nil
                    wasTapped = true
                    error = ""
                    viewModel.getInteractionsFromTwoMedications() { error in
                        if let error = error {
                            self.error = error
                        }
                    }
                } label: {
                    Text("Check")
                        .foregroundColor(.white)
                        .padding([.leading, .trailing], 16)
                        .padding([.top, .bottom], 6)
                        .buttonBorderShape(.roundedRectangle)
                        .background(viewModel.shouldDisableButton() ? Color.gray : Color.buttonPurple)
                        .cornerRadius(16)
                }
                .disabled(viewModel.shouldDisableButton())
                .padding([.top, .bottom], 16)
                
                if wasTapped && error.isEmpty && viewModel.getInformationFromTwoMedications() == nil {
                    ProgressView()
                } else {
                    if !error.isEmpty {
                        Text(error)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.lightPurple)
                            .cornerRadius(12)
                            .padding([.leading, .trailing], 16)
                            .padding(.bottom, 8)
                    } else {
                        if let interaction = viewModel.getInformationFromTwoMedications() {
                            Text(interaction)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.lightPurple)
                                .cornerRadius(12)
                                .padding([.leading, .trailing], 16)
                                .padding(.bottom, 8)
                        }
                    }
                }
            }
        }
    }
}
