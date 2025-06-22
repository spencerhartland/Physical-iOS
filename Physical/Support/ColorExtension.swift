//
//  ColorExtension.swift
//  Physical
//
//  Created by Spencer Hartland on 6/22/25.
//

import SwiftUI

extension Color {
    public func alpha() -> Float {
        let resolvedColor = self.resolve(in: EnvironmentValues())
        return resolvedColor.opacity
    }
}
