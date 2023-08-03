//
//  HapticsViewExtension.swift
//  Physical
//
//  Created by Spencer Hartland on 7/24/23.
//

import SwiftUI

extension View {
    func impactFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}
