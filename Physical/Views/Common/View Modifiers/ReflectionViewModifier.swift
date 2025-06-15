//
//  BlurredReflectionViewModifier.swift
//  Physical
//
//  Created by Spencer Hartland on 7/17/23.
//

import SwiftUI

private struct ReflectionViewModifier: ViewModifier {
    let screenSize: CGSize
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    content
                        .blur(radius: 8.0)
                    content
                        .blur(radius: 16.0)
                }
                    .opacity(0.33)
                    .rotation3DEffect(
                        .degrees(Motion.main.roll(limited: true)),
                        axis: (x: 0, y: -1, z: 0))
                    .rotation3DEffect(
                        .degrees(Motion.main.pitch(limited: true)),
                        axis: (x: -1, y: 0, z: 0))
                    .rotation3DEffect(
                        .degrees(Motion.main.yaw(limited: true)),
                        axis: (x: 0, y: 0, z: 1))
            )
    }
}

extension View {
    func reflection(screenSize: CGSize) -> some View {
        modifier(ReflectionViewModifier(screenSize: screenSize))
    }
}
