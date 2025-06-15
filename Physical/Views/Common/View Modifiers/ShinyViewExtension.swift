//
//  ShinyViewModifier.swift
//
//
//  Created by Spencer Hartland on 2/1/24.
//

import SwiftUI
import CoreMotion

public extension View {
    func shiny(_ surface: Gradient = .rainbow) -> some View {
        return ShinyView(surface, content: self).environmentObject(Motion.main)
    }
}

internal struct ShinyView<Content>: View where Content: View {
    
    @EnvironmentObject var model: Motion
    
    init(_ surface: Gradient = .rainbow, content: Content) {
        self.surface = surface
        self.content = content
    }
    
    init(_ surface: Gradient = .rainbow, @ViewBuilder content: () -> Content) {
        self.surface = surface
        self.content = content()
    }
    
    var content: Content
    
    var position: CGSize {
        let x = 0 - (CGFloat(model.roll()) / .pi * 4) * UIScreen.main.bounds.height
        let y = 0 - (CGFloat(model.pitch()) / .pi * 4) * UIScreen.main.bounds.height
        return CGSize(width: x, height: y)
    }
    
    func scale(_ proxy: GeometryProxy) -> CGFloat {
        return UIScreen.main.bounds.height / radius(proxy) * 2
    }
    
    func radius(_ proxy: GeometryProxy) -> CGFloat {
        return min(proxy.frame(in: .global).width / 2, proxy.frame(in: .global).height / 2)
    }
    
    var surface: Gradient
    
    var body: some View {
        content
            .overlay(
                GeometryReader { (proxy) in
                    ZStack {
                        self.surface.stops.last?.color
                            .scaleEffect(self.scale(proxy))
                        withAnimation {
                            RadialGradient(
                                gradient: self.surface,
                                center: .center,
                                startRadius: 1,
                                endRadius: self.radius(proxy)
                            )
                            .scaleEffect(self.scale(proxy))
                            .offset(self.position)
                        }
                    }
                    .mask(self.content)
                }
            )
            .shadow(radius: 6)
    }
}
