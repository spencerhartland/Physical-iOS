//
//  MediaAddedNotificationView.swift
//  Physical
//
//  Created by Spencer Hartland on 4/2/25.
//

import SwiftUI

struct MediaAddedNotificationView: View {
    private let notificationTitle = "Added to Collection"
    private let notificationSymbolName = "checkmark"
    
    @State private var symbolAnimate = false
    
    @State private var strokeStartPoint = UnitPoint(x: 0, y: 0)
    @State private var strokeEndPoint = UnitPoint(x: 1, y: 1)
    
    var body: some View {
        HStack {
            Image(systemName: notificationSymbolName)
                .symbolEffect(.bounce, options: .nonRepeating, isActive: symbolAnimate)
            Text(notificationTitle)
        }
        .font(.headline)
        .foregroundStyle(.darkGreen)
        .padding()
        .background {
            notificationBackground
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                symbolAnimate = true
                impactFeedback(.medium)
            }
        }
    }
    
    private var notificationBackground: some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(.thinMaterial)
            
            Capsule(style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            .lightGreen.opacity(0.85),
                            .lightGreen.opacity(0.45),
                            .lightGreen.opacity(0.25),
                            .lightGreen.opacity(0.15),
                            .lightGreen.opacity(0.10),
                            .lightGreen.opacity(0.05)
                        ],
                        startPoint: .topTrailing,
                        endPoint: .bottom
                    )
                )
                .fill(
                    LinearGradient(
                        colors: [
                            .lightGreen.opacity(0.65),
                            .lightGreen.opacity(0.05)
                        ],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                )
        }
    }
}

#Preview {
    ZStack {
        Color(UIColor.systemBackground)
            .ignoresSafeArea()
        
        MediaAddedNotificationView()
    }
}
