//
//  VariableBlurNavigationBackgroundViewModifier.swift
//  Physical
//
//  Created by Spencer Hartland on 8/15/23.
//

import SwiftUI

struct VariableBlurNavigationBackgroundViewModifier: ViewModifier {
    private let blurPrimaryColor = Color(UIColor.secondarySystemBackground)
    
    @Environment(\.screenSize) private var screenSize
    
    func body(content: Content) -> some View {
        let height = screenSize.height * 0.15
        
        ZStack(alignment: .top) {
            content
            Rectangle()
                .frame(height: height)
                .foregroundStyle(.ultraThinMaterial)
                .mask {
                    LinearGradient(
                        stops: [
                            .init(color: blurPrimaryColor.opacity(0.66), location: 0.33),
                            .init(color: blurPrimaryColor.opacity(0.33), location: 0.66),
                            .init(color: blurPrimaryColor.opacity(0.165), location: 0.85),
                            .init(color: .clear, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .ignoresSafeArea()
        }
    }
}

extension View {
    func variableBlurNavigationBackground() -> some View {
        modifier(VariableBlurNavigationBackgroundViewModifier())
    }
}

#Preview {
    @Previewable @State var screenSize: CGSize = {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        return window.screen.bounds.size
    }()
    
    return NavigationStack {
        List {
            Text("Item 1")
            Text("Item 2")
            Text("Item 3")
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.thickMaterial)
            }
        }
        .ignoresSafeArea()
        .variableBlurNavigationBackground()
    }
    .environment(\.screenSize, screenSize)
}
