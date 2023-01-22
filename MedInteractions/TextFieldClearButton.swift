//
//  TextFieldClearButton.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//

import Foundation
import SwiftUI

struct TextFieldClearButton: ViewModifier {
    @Binding var fieldText: String

    func body(content: Content) -> some View {
        ZStack {
            content
            if !fieldText.isEmpty {
                HStack {
                    Spacer()
                    Button {
                        fieldText = ""
                    } label: {
                        Image(systemName: "multiply.circle.fill")
                    }
                    .foregroundColor(.secondary)
                    .padding(.trailing, 4)
                }
            }
        }
    }
}

extension View {
    func withClearButton(_ text: Binding<String>) -> some View {
        self.modifier(TextFieldClearButton(fieldText: text))
    }
}

