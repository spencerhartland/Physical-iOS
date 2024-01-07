//
//  OnboardingSignUpView.swift
//  Physical
//
//  Created by Spencer Hartland on 11/8/23.
//

import SwiftUI

struct OnboardingSignUpView: View {
    private let signUpSymbolName = "person.crop.square.filled.and.at.rectangle.fill"
    private let usernameTextfieldSymbolName = "at"
    private let validInputSymbolName = "checkmark.circle"
    private let invalidInputSymbolName = "x.circle"
    
    private let signUpTitleText = "One more thing..."
    private let signUpSubtitleText = "Enter your desired username to finish setting up your account."
    private let usernameTextFieldLabelText = "Username"
    private let buttonText = "Continue"
    private let usernameInvalidText = "Your username must only contain letters and numbers."
    private let usernameUnavailableText = "This username is unavailable. Please choose another one."
    
    @AppStorage(StorageKeys.userID) private var userID: String = ""
    
    @Binding var signInSheetPresented: Bool
    
    @State private var desiredUsername: String = ""
    @State private var inputValid: Bool = false
    @State private var usernameIsAvailable: Bool = true
    @State private var waiting: Bool = false
    @State private var userAccountCreationFailed: Bool = false
    
    private let userAccountManager = UserAccountManager()
    
    init(_ signInSheetPresented: Binding<Bool>) {
        self._signInSheetPresented = signInSheetPresented
    }
    
    var body: some View {
        UserInputRequiredView(
            symbolName: signUpSymbolName,
            title: signUpTitleText,
            subtitle: signUpSubtitleText) {
                VStack {
                    usernameField
                    Text((!inputValid && !desiredUsername.isEmpty) ? usernameInvalidText : usernameIsAvailable ? " " : usernameUnavailableText)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding(4)
                    createAccountButton
                }
            }
        // TODO: Navigate to error view when account creation fails
    }
    
    private var usernameField: some View {
        HStack {
            Image(systemName: usernameTextfieldSymbolName)
                .foregroundStyle(.secondary)
            TextField(text: $desiredUsername) {
                Text(usernameTextFieldLabelText)
            }
            .textInputAutocapitalization(.never)
            .onChange(of: desiredUsername) { _, _ in
                validateInput()
            }
            if !desiredUsername.isEmpty {
                Image(systemName: inputValid ? validInputSymbolName : invalidInputSymbolName)
                    .foregroundStyle(inputValid ? .green : .red)
                    .contentTransition(.symbolEffect(.replace))
                    .transition(.symbolEffect(.appear))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 4)
                .foregroundStyle(Color(uiColor: .secondarySystemBackground))
        }
    }
    
    private var createAccountButton: some View {
        Button {
            waiting = true
            Task {
                if await checkAvailability(of: desiredUsername) {
                    await createUserAccount()
                    signInSheetPresented = false
                }
                waiting = false
            }
        } label: {
            if waiting {
                ProgressView()
            } else {
                Text(buttonText)
            }
        }
        .font(.body.bold())
        .disabled(!inputValid || !usernameIsAvailable)
    }
    
    // MARK: - Input validation
    
    // Validates the `username` entered by the user.
    private func validateInput() {
        var valid = CharacterSet()
        valid.formUnion(.lowercaseLetters)
        valid.formUnion(.uppercaseLetters)
        valid.formUnion(.decimalDigits)
        
        inputValid = !desiredUsername.isEmpty && desiredUsername.unicodeScalars.allSatisfy { valid.contains($0) }
    }
    
    // Checks if the provided `username` is taken and updates `usernameIsAvailable`.
    private func checkAvailability(of username: String) async -> Bool {
        if (try? await userAccountManager.fetchUserID(for: username)) != nil {
            usernameIsAvailable = false
            return false
        } else {
            usernameIsAvailable = true
            return true
        }
    }
    
    // MARK: - User account creation
    
    // Creates a user accound by using the Physical API to upload a `User` obtained
    // from `createUser()`.
    private func createUserAccount() async {
        let newUser = createUser()
        do {
            try await userAccountManager.createAccount(for: newUser)
            handleAccountCreationSuccess()
        } catch {
            handleAccountCreationFailure(error)
        }
    }
    
    // Creates an instance of `User` with the authenticated user's information.
    private func createUser() -> User {
        let newUserCollectionID = UUID().uuidString
        UserDefaults.standard.set(newUserCollectionID, forKey: StorageKeys.collectionID)
        return User(with: userID, username: desiredUsername, collection: newUserCollectionID)
    }
    
    private func handleAccountCreationSuccess() {
        signInSheetPresented = false
    }
    
    private func handleAccountCreationFailure(_ error: Error) {
        print(error.localizedDescription)
        userAccountCreationFailed = true
    }
}

#Preview {
    OnboardingSignUpView(.constant(true))
}
