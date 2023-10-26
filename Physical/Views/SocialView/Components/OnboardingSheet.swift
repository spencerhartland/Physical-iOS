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
    // Share Collection feature
    private var shareCollectionFeatureTitle = "Shareable Collection"
    private var shareCollectionFeatureDescription = "Share your digital collection with anyone."
    private var shareCollectionFeatureSymbolName = "square.and.arrow.up.circle.fill"
    // No account button
    private var noAccountButtonText = "Continue without an account"
    // Account not required footer
    private var accountNotRequiredFooterText = "An account is not required to use Physical, just for access to the features described above."
    
    @Environment(\.screenSize) private var screenSize: CGSize
    @Environment(\.colorScheme) private var colorScheme
    
    @Binding var shouldRequestSignIn: Bool
    
    init(_ shouldRequestSignIn: Binding<Bool>) {
        self._shouldRequestSignIn = shouldRequestSignIn
    }
    
    var body: some View {
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
                // Share library
                featureCallout(
                    shareCollectionFeatureTitle,
                    description: shareCollectionFeatureDescription,
                    symbolName: shareCollectionFeatureSymbolName
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
                shouldRequestSignIn = false
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
                    print("Success!")
                case .failure(let error):
                    print(error.localizedDescription)
                    // TODO: Let the user know that auth failed
                }
            }
        }
        // Dismiss onboarding sheet
        shouldRequestSignIn = false
    }
    
    private func handleAuthorizationFailure(_ error: Error) {
        // TODO: handle this
        print(error.localizedDescription)
    }
}

#Preview {
    @State var screenSize: CGSize = {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        return window.screen.bounds.size
    }()
    
    let authManager = AuthenticationManager()
    
    return Text("Preview")
        .sheet(isPresented: .constant(true)) {
            OnboardingSheet(.constant(true))
        }
        .environment(\.screenSize, screenSize)
}
