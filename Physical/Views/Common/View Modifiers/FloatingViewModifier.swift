//
//  FloatingViewModifier.swift
//  Physical
//
//  Created by Spencer Hartland on 7/20/23.
//

import SwiftUI

struct FloatingViewModifier: ViewModifier {
    let screenSize: CGSize
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .rotation3DEffect(
                .degrees(Motion.main.roll(limited: true)),
                axis: (x: 0, y: 1, z: 0)
            )
            .rotation3DEffect(
                .degrees(Motion.main.pitch(limited: true)),
                axis: (x: 1, y: 0, z: 0)
            )
            .rotation3DEffect(
                .degrees(Motion.main.yaw(limited: true)),
                axis: (x: 0, y: 0, z: 1)
            )
    }
}

extension View {
    func floating(screenSize: CGSize) -> some View {
        modifier(FloatingViewModifier(screenSize: screenSize))
    }
}
