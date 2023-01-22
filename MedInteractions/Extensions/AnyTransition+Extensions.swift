//
//  AnyTransition+Extensions.swift
//  MedInteractions
//
//  Created by Joanna Staleńczyk on 22/01/2023.
//

import Foundation
import SwiftUI

extension AnyTransition {
    static var confetti: AnyTransition {
        .modifier(
            active: ConfettiModifier(color: .blue, size: 3),
            identity: ConfettiModifier(color: .blue, size: 3)
        )
    }
    
    static func confetti<T: ShapeStyle>(
        color: T = .blue,
        size: Double = 3.0
    ) -> AnyTransition {
        AnyTransition.modifier(
            active: ConfettiModifier(color: color, size: size),
            identity: ConfettiModifier(color: color, size: size)
        )
    }
}

struct ConfettiModifier<T: ShapeStyle>: ViewModifier {
    @State private var confettiIsHidden = true
    @State private var confettiMovement = 1.0
    @State private var confettiScale = 1.0
    private let speed = 0.4
    @State private var colors = [
        Color.darkPurple!,
        Color.lightPurple!,
        Color.buttonPurple!
    ]
    var color: T
    var size: Double
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    GeometryReader { proxy in
                        ForEach(0..<15) { i in
                            Circle()
                                .fill(colors.randomElement()!)
                                .frame(
                                    width: size + sin(Double(i)),
                                    height: size + sin(Double(i))
                                )
                                .scaleEffect(confettiScale)
                                .offset(
                                    x: proxy.size.width / 2 * confettiMovement
                                    + (i.isMultiple(of: 2) ? size : 0)
                                )
                                .rotationEffect(.degrees(24 * Double(i)))
                                .offset(
                                    x: (proxy.size.width - size) / 2,
                                    y: (proxy.size.height - size) / 2
                                )
                                .opacity(confettiIsHidden ? 0 : 1)
                        }
                    }
                    content
                }
            )
            .onAppear {
                withAnimation(.interpolatingSpring(stiffness: 50, damping: 5)) {
                    confettiScale = 1
                }
                withAnimation(.easeOut(duration: speed)) {
                    confettiIsHidden = false
                    confettiMovement = 1.8
                }
                withAnimation(.easeInOut(duration: speed*2)) {
                    confettiScale = 0.00001
                }
            }
    }
}

extension Animation {
    static var easeInOutBack: Animation {
        Animation.timingCurve(0.5, -0.5, 0.5, 1.5)
    }
    
    static func easeInOutBack(duration: TimeInterval = 0.2) -> Animation {
        Animation.timingCurve(2, -0.5, 0.3, 1.5, duration: duration)
    }
}
