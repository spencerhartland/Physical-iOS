//
//  ButtonStyle.swift
//  Physical
//
//  Created by Spencer Hartland on 1/2/26.
//

import SwiftUI

extension View {
    @ViewBuilder
    func standardButtonStyle(isEnabled: Bool = true) -> some View {
        if isEnabled {
            if #available(iOS 26.0, *) {
                self.buttonStyle(.glass)
            } else {
                self.buttonStyle(.bordered)
            }
        } else {
            self
        }
    }
    
    @ViewBuilder
    func prominentButtonStyle(isEnabled: Bool = true) -> some View {
        if isEnabled {
            if #available(iOS 26.0, *) {
                self.buttonStyle(.glassProminent)
            } else {
                self.buttonStyle(.borderedProminent)
            }
        } else {
            self
        }
    }
}
