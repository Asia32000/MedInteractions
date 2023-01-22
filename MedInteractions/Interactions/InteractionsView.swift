//
//  InteractionsView.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//

import SwiftUI

struct InteractionsView: View {
    @ObservedObject var viewModel: InteractionsViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.items, id: \.self) { item in
                    Section {
                        NavigationLink(destination: InteractionsItemView(name: item)) {
                            HStack {
                                item.image
                                    .padding(.trailing, 6)
                                Text(item)
                                    .font(.custom("OldStandardTT-Regular", size: 18))
                            }
                        }
                    }
                }
            }
        }
    }
}

struct InteractionsItemView: View {
    var name: String
    var body: some View {
        switch name {
        case "Single medication":
            SingleMedicationView(viewModel: InteractionsViewModel(), rxcuiService: FindRxcuiService())
        case "Two medications":
            TwoMedicationsView(viewModel: InteractionsViewModel())
        default:
            fatalError()
        }
    }
}

private extension String {
    var image: Image {
        switch self {
        case "Single medication":
            return Image.Interactions.pill
        case "Two medications":
            return Image.Interactions.pills
        default:
            return Image(systemName: "questionmark")
        }
    }
}
