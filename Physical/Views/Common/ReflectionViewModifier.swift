//
//  BlurredReflectionViewModifier.swift
//  Physical
//
//  Created by Spencer Hartland on 7/17/23.
//

import SwiftUI

private struct BlurredReflectionViewModifier: ViewModifier {
    var roll: Double
    var pitch: Double
    var yaw: Double
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
                    .rotation3DEffect(.degrees(roll), axis: (x: 0, y: 1, z: 0))
                    .rotation3DEffect(.degrees(pitch), axis: (x: 1, y: 0, z: 0))
                    .rotation3DEffect(.degrees(yaw), axis: (x: 0, y: 0, z: 1))
            )
    }
}

extension View {
    func reflection(roll: Double, pitch: Double, yaw: Double, screenSize: CGSize) -> some View {
        modifier(BlurredReflectionViewModifier(roll: roll, pitch: pitch, yaw: yaw, screenSize: screenSize))
    }
}
