//
//  NoAccountView.swift
//  Physical
//
//  Created by Spencer Hartland on 10/13/23.
//

import SwiftUI
import AuthenticationServices

struct NoAccountView: View {
    private let noAccountSymbolName = "at.circle"
    private let noAccountTitleText = "Signed out!"
    private let noAccountSubtitleText = "You must be signed in to access Physical's social features. Tap the button below to sign in or create an account.\n\nSocial features can be toggled off in Settings under Physical > Show Social and Profile tabs."
    
    @Environment(\.screenSize) private var screenSize: CGSize
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    var body: some View {
        UserInputRequiredView(
            symbolName: noAccountSymbolName,
            title: noAccountTitleText,
            subtitle: noAccountSubtitleText) {
                SignInWithAppleButton(.continue) { request in
                    request.requestedScopes = []
                } onCompletion: { result in
                    switch result {
                    case .success/*(let authorization)*/:
                        print("Authorization successful")
                    case .failure(let error):
                        print("Authorization error: \(error.localizedDescription)")
                    }
                }
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .frame(height: screenSize.height / 16)
        }
    }
}

#Preview {
    @Previewable @State var screenSize: CGSize = {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        return window.screen.bounds.size
    }()
    
    return NoAccountView()
        .environment(\.screenSize, screenSize)
}
