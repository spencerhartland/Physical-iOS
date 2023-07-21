//
//  FloatingViewModifier.swift
//  Physical
//
//  Created by Spencer Hartland on 7/20/23.
//

import SwiftUI

struct FloatingViewModifier: ViewModifier {
    var roll: Double
    var pitch: Double
    var yaw: Double
    let screenSize: CGSize
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .rotation3DEffect(.degrees(roll), axis: (x: 0, y: 1, z: 0))
            .rotation3DEffect(.degrees(pitch), axis: (x: 1, y: 0, z: 0))
            .rotation3DEffect(.degrees(yaw), axis: (x: 0, y: 0, z: 1))
    }
}

extension View {
    func floating(roll: Double, pitch: Double, yaw: Double, screenSize: CGSize) -> some View {
        modifier(FloatingViewModifier(roll: roll, pitch: pitch, yaw: yaw, screenSize: screenSize))
    }
}
