//
//  NavigationSubtitleViewModifier.swift
//  Physical
//
//  Created by Spencer Hartland on 5/8/26.
//

import SwiftUI

public extension View {
    func navigationSubtitleIfAvailable(_ subtitle: Text) -> some View {
        modifier(NavigationSubtitleViewModifier(subtitle))
    }
}

internal struct NavigationSubtitleViewModifier: ViewModifier {
    let subtitle: Text
    
    init(_ subtitle: Text) {
        self.subtitle = subtitle
    }
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .navigationSubtitle(subtitle)
        } else {
            content
        }
    }
}
