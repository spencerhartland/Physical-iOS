//
//  BlurredReflectionViewModifier.swift
//  Physical
//
//  Created by Spencer Hartland on 7/17/23.
//

import SwiftUI

private struct BlurredReflectionViewModifier: ViewModifier {
    @Binding var offset: CGSize
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
                .rotation3DEffect(calculateAngle(onXAxis: true), axis: (x: 1, y: 0, z: 0))
                .rotation3DEffect(calculateAngle(onXAxis: false), axis: (x: 0, y: -1, z: 0))
            )
    }
    
    private func calculateAngle(onXAxis: Bool) -> Angle {
        let progress = (onXAxis ? offset.height : offset.width) / (onXAxis ? screenSize.height : screenSize.width)
        return .init(degrees: progress * 10)
    }
}

extension View {
    func reflection(offset: Binding<CGSize>, screenSize: CGSize) -> some View {
        modifier(BlurredReflectionViewModifier(offset: offset, screenSize: screenSize))
    }
}
