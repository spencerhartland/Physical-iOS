//
//  OnboardingSignUpView.swift
//  Physical
//
//  Created by Spencer Hartland on 11/8/23.
//

import SwiftUI

struct OnboardingSignUpView: View {
    private let signUpSymbolName = "person.crop.square.filled.and.at.rectangle.fill"
    private let signUpTitleText = "One last detail..."
    private let signUpSubtitleText = "Enter your desired username and tap \"Continue\" to finish creating your account."
    private let usernameTextFieldLabelText = "Username"
    private let buttonText = "Continue"
    
    @State private var desiredUsername: String = ""
    @State private var inputValid: Bool = false
    
    var body: some View {
        UserInputRequiredView(
            symbolName: signUpSymbolName,
            title: signUpTitleText,
            subtitle: signUpSubtitleText) {
                VStack(spacing: 32) {
                    usernameField
                    Button(buttonText) {
                        print("Continuinggggg")
                    }
                    .font(.body.bold())
                    .disabled(!inputValid)
                }
            }
    }
    
    private var usernameField: some View {
        HStack {
            Image(systemName: "at")
                .foregroundStyle(.secondary)
            TextField(text: $desiredUsername) {
                Text(usernameTextFieldLabelText)
            }
            .onChange(of: desiredUsername) { _, _ in
                validateInput()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 4)
                .foregroundStyle(Color(uiColor: .secondarySystemBackground))
        }
    }
    
    private func validateInput() {
        var valid = CharacterSet()
        valid.formUnion(.lowercaseLetters)
        valid.formUnion(.uppercaseLetters)
        valid.formUnion(.decimalDigits)
        
        inputValid = !desiredUsername.isEmpty && desiredUsername.unicodeScalars.allSatisfy { valid.contains($0) }
    }
}

#Preview {
    @State var screenSize: CGSize = {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        return window.screen.bounds.size
    }()
    
    return OnboardingSignUpView()
        .environment(\.screenSize, screenSize)
}
