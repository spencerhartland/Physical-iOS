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
    private let noAccountSubtitleText = "You must be signed in to access social features. Tap the button below to sign in or create an account.\n\nYou can hide Physical's social features in the system Settings app under Physical > Hide social features."
    
    @Environment(\.screenSize) private var screenSize: CGSize
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: noAccountSymbolName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: screenSize.width / 6)
            Text(noAccountTitleText)
                .font(.title.bold())
            Text(noAccountSubtitleText)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .font(.callout)
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
            .padding(.top, 32)
        }
        .padding(.horizontal)
    }
}

#Preview {
    @State var screenSize: CGSize = {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        return window.screen.bounds.size
    }()
    
    return NoAccountView()
        .environment(\.screenSize, screenSize)
}
