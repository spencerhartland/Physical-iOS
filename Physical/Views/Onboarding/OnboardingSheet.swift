//
//  OnboardingView.swift
//  Physical
//
//  Created by Spencer Hartland on 9/19/23.
//

import SwiftUI
import AuthenticationServices

struct OnboardingSheet: View {
    private var welcomeText = "Welcome to Physical"
    private var introText = "The digital catalogue of your music on physical media. Create an account to gain access to additional features:"
    // Social Profile feautre
    private var socialProfileFeatureTitle = "Social Profile"
    private var socialProfileFeatureDescription = "Share, discover, and discuss music with friends."
    private var socialProfileFeatureSymbolName = "at.circle.fill"
    // Public Collection feature
    private var publicCollectionFeatureTitle = "Public Collection"
    private var publicCollectionFeatureDescription = "Share your collection with just a link."
    private var publicCollectionFeatureSymbolName = "square.and.arrow.up.circle.fill"
    // Shared Collection feature
    private var sharedCollectionFeatureTitle = "Shared Collection"
    private var sharedCollectionFeatureDescription = "Collaboratively manage a shared collection."
    private var sharedCollectionFeatureSymbolName = "person.2.circle.fill"
    // No account button
    private var noAccountButtonText = "Continue without an account"
    // Account not required footer
    private var accountNotRequiredFooterText = "An account is not required to use Physical, just for access to the features described above."
    
    @Environment(\.screenSize) private var screenSize: CGSize
    @Environment(\.colorScheme) private var colorScheme
    
    @Binding var signInSheetPresented: Bool
    @State private var signInSuccessful: Bool = false
    
    init(_ shouldRequestSignIn: Binding<Bool>) {
        self._signInSheetPresented = shouldRequestSignIn
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                appIcon(screenSize.width / 4)
                    .padding(.bottom)
                Text(welcomeText)
                    .font(.title.bold())
                    .padding(.bottom)
                Text(introText)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .font(.callout)
                
                Spacer()
                
                VStack(alignment: .leading) {
                    // Social Profile
                    featureCallout(
                        socialProfileFeatureTitle,
                        description: socialProfileFeatureDescription,
                        symbolName: socialProfileFeatureSymbolName
                    )
                    // Public collection
                    featureCallout(
                        publicCollectionFeatureTitle,
                        description: publicCollectionFeatureDescription,
                        symbolName: publicCollectionFeatureSymbolName
                    )
                    // Shared collection
                    featureCallout(
                        sharedCollectionFeatureTitle,
                        description: sharedCollectionFeatureDescription,
                        symbolName: sharedCollectionFeatureSymbolName
                    )
                }
                
                Spacer()
                
                SignInWithAppleButton { request in
                    request.requestedScopes = [.email]
                } onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        handleAuthorizationSuccess(authorization)
                    case .failure(let error):
                        handleAuthorizationFailure(error)
                    }
                }
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .frame(height: screenSize.height / 16)
                
                Button {
                    signInSheetPresented = false
                } label: {
                    Text(noAccountButtonText)
                        .font(.body.bold())
                }
                .padding(.top)
                
                Text(accountNotRequiredFooterText)
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.top)
            }
            .padding([.top, .horizontal])
            .navigationDestination(isPresented: $signInSuccessful) {
                OnboardingSignUpView($signInSheetPresented)
                    .navigationBarBackButtonHidden()
            }
        }
    }
    
    private func appIcon(_ size: CGFloat) -> some View {
        let iconCornerRadius = (10 / 57) * size
        let iconRect = RoundedRectangle(cornerRadius: iconCornerRadius)
        
        return Image(.physicalIcon)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .clipShape(iconRect)
            .overlay {
                iconRect
                    .stroke(lineWidth: 0.15)
                    .foregroundStyle(.primary)
            }
            .shadow(radius: 4)
    }
    
    private func featureCallout(
        _ feature: String,
        description: String,
        symbolName: String
    ) -> some View {
        HStack {
            Image(systemName: symbolName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(8)
                .frame(width: screenSize.width / 6)
            VStack(alignment: .leading) {
                Text(feature)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - Authentication Logic
    
    private func handleAuthorizationSuccess(_ authorization: ASAuthorization) {
        Task {
            await AuthenticationManager.shared.authenticate(with: authorization) { result in
                switch result {
                case .success:
                    signInSuccessful = true
                case .failure(let error):
                    print(error.localizedDescription)
                    // TODO: Let the user know that auth failed
                }
            }
        }
    }
    
    private func handleAuthorizationFailure(_ error: Error) {
        // TODO: handle this
        print(error.localizedDescription)
    }
}
