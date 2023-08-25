//
//  ScreenSize.swift
//  Physical
//
//  Created by Spencer Hartland on 8/24/23.
//

import SwiftUI

struct ScreenSizeKey: EnvironmentKey {
    static var defaultValue: CGSize = .zero
}

extension EnvironmentValues {
    var screenSize: CGSize {
        get { self[ScreenSizeKey.self] }
        set { self[ScreenSizeKey.self] = newValue }
    }
}
