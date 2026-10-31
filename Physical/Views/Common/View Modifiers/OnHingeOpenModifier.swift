//
//  OnHingeOpenModifier.swift
//  Physical
//
//  Created by Spencer Hartland on 10/31/26.
//

import SwiftUI

struct OnHingeOpenModifier: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        if #available(anyAppleOS 27.1, *) {
            content
                .onHingeChange { oldContext, newContext in
                    if let oldStatus = oldContext.hinge?.status,
                       let newStatus = newContext.hinge?.status {
                        if oldStatus == .closed && newStatus != oldStatus { action() }
                    }
                }
        } else {
            content
        }
    }
}

extension View {
    func onHingeOpen(_ action: @escaping () -> Void) -> some View {
        modifier(OnHingeOpenModifier(action: action))
    }
}
