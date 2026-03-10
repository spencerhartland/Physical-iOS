//
//  MediaAddedToastView.swift
//  Physical
//
//  Created by Spencer Hartland on 1/17/26.
//

import SwiftUI

extension View {
    @ViewBuilder func mediaAddedToast(isPresented: Binding<Bool>) -> some View {
        modifier(MediaAddedToastViewModifier(isPresented: isPresented))
    }
}

struct MediaAddedToastViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if isPresented {
                    Label("Added to Collection", systemImage: "checkmark.circle.fill")
                        .padding(18)
                        .fontWeight(.medium)
                        .background {
                            if #available(iOS 26.0, *) {
                                Capsule()
                                    .foregroundStyle(.clear)
                                    .glassEffect()
                            } else {
                                Capsule()
                                    .foregroundStyle(.ultraThickMaterial)
                            }
                        }
                        .padding(.top)
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation { isPresented = false }
                            }
                        }
                }
            }
    }
}
