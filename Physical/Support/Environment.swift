//
//  Environment.swift
//  Physical
//
//  Created by Spencer Hartland on 2/4/26.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var navigationManager: NavigationManager = NavigationManager()
    @Entry var screenSize: CGSize = {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        return window.screen.bounds.size
    }()
}
