//
//  DrugInteractionsCheckerView.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//

import SwiftUI

struct DrugInteractionsCheckerView: View {
    var body: some View {
        HStack {
            Text("Drug Interactions Checker")
                .font(.custom("OldStandardTT-Regular", size: 24))
                .padding(.trailing, 12)
            Image.Interactions.interactionsChecker
        }
        .padding([.top, .bottom], 12)
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color.lightPurple)
    }
}
