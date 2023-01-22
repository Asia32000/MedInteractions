//
//  SingleMedicationView.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//

import SwiftUI

struct SingleMedicationView: View {
    @ObservedObject var viewModel: InteractionsViewModel
    @ObservedObject var rxcuiService: FindRxcuiService
    
    var body: some View {
        ScrollView {
            VStack {
                DrugInteractionsCheckerView()
                    .padding(.bottom, 36)
                
                Group {
                    TextField("Enter a drug name", text: $viewModel.drugName)
                        .withClearButton($viewModel.drugName)
                        .padding(4)
                        .padding(.leading, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.darkPurple!, lineWidth: 1)
                        )
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .onTapGesture {
                            hideKeyboard()
                    }
                }
                .padding([.trailing, .leading])
                
                Button {
                    hideKeyboard()
                    viewModel.clearInteractions()
                    viewModel.getInteractions() { error in
                        if let error = error {
                            viewModel.rxcuiError = error
                        }
                    }
                } label: {
                    Text("Check")
                        .foregroundColor(.white)
                        .padding([.leading, .trailing], 16)
                        .padding([.top, .bottom], 6)
                        .buttonBorderShape(.roundedRectangle)
                        .background(viewModel.drugName.isEmpty ? Color.gray : Color.buttonPurple)
                        .cornerRadius(16)
                }
                .disabled(viewModel.drugName.isEmpty)
                .padding([.top, .bottom], 16)
                
                if viewModel.shouldShowProgressView() {
                    ProgressView()
                } else {
                    if !viewModel.rxcuiError.isEmpty {
                        Text(viewModel.rxcuiError)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.lightPurple)
                            .cornerRadius(12)
                            .padding([.leading, .trailing], 16)
                            .padding(.bottom, 8)
                    } else {
                        ForEach(viewModel.displayedInteractionsArray, id: \.self) { interaction in
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
                
                if !viewModel.displayedInteractionsArray.isEmpty {
                    Button {
                        viewModel.getTenMoreInteractions()
                    } label: {
                        Text("Load more")
                            .foregroundColor(.white)
                            .padding([.leading, .trailing], 16)
                            .padding([.top, .bottom], 6)
                            .buttonBorderShape(.roundedRectangle)
                            .background(Color.buttonPurple)
                            .cornerRadius(16)
                    }
                    .padding([.top, .bottom], 8)
                }
            }
        }
    }
}
