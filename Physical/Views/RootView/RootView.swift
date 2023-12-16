//
//  RootView.swift
//  Physical
//
//  Created by Spencer Hartland on 8/24/23.
//

import SwiftUI

struct RootView: View {
    private let collectionTabItemText = "Collection"
    private let socialTabItemText = "Social"
    private let profileTabItemText = "Profile"
    
    private let collectionTabItemSymbol = "square.stack.fill"
    private let socialTabItemSymbol = "at.circle.fill"
    private let profileTabItemSymbol = "person.crop.circle.fill"
    
    @AppStorage(StorageKeys.userID) private var userID: String = ""
    @State private var shouldRequestSignIn: Bool = true
    @State private var screenSize: CGSize = {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        return window.screen.bounds.size
    }()
    
    var body: some View {
        TabView {
            MediaCollectionView()
                .tabItem {
                    Label(collectionTabItemText, systemImage: collectionTabItemSymbol)
                }
            noAccountView
                .tabItem {
                    Label(socialTabItemText, systemImage: socialTabItemSymbol)
                }
            noAccountView
                .tabItem {
                    Label(profileTabItemText, systemImage: profileTabItemSymbol)
                }
        }
        .environment(\.screenSize, screenSize)
        .onAppear {
            // If there is a user ID in UserDefaults, do not ask to sign in.
            if !userID.isEmpty {
                // UNDO COMMENT shouldRequestSignIn = false
            }
        }
    }
    
    private var noAccountView: some View {
        NoAccountView()
            .sheet(isPresented: $shouldRequestSignIn) {
                OnboardingSheet($shouldRequestSignIn)
            }
    }
}

#Preview {
    RootView()
        .modelContainer(previewContainer)
}
