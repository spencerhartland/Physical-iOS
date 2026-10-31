//
//  GlassTextFieldStyleModifier.swift
//  Physical
//
//  Created by Spencer Hartland on 10/29/26.
//

import SwiftUI

struct GlassTextFieldStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(anyAppleOS 26.0, *) {
            content
                .textFieldStyle(.plain)
                .padding(.vertical, 12)
                .padding(.horizontal)
                .glassEffect(.regular.interactive(), in: .capsule)
        } else {
            content
                .textFieldStyle(.plain)
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background { Color(uiColor: .secondarySystemBackground).clipShape(.capsule) }
        }
    }
}

extension View where Self == TextField<Text> {
    func glassTextfieldStyle() -> some View {
        modifier(GlassTextFieldStyleModifier())
    }
}
