//
//  MusicAuthorizationViewModifier.swift
//  Physical
//
//  Created by Spencer Hartland on 11/7/26.
//

import MusicKit
import SwiftUI

struct MusicAuthorizationViewModifier: ViewModifier {
    @Environment(\.openURL) private var openURL
    
    @AppStorage(StorageKeys.shouldAskForAppleMusicAuthorization)
    private var shouldAskForAppleMusicAuthorization: Bool = true
    
    @State private var musicAuthorizationStatus = MusicAuthorization.currentStatus
    @State private var shouldConfirmSelection = false
    
    func body(content: Content) -> some View {
        content
            .task { await checkMusicAuthorization() }
            .alert(
                "Physical uses Apple Music for search results",
                isPresented: $shouldConfirmSelection
            ) {
                Button("Enable in Settings") {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        openURL(settingsURL)
                    }
                }
                Button("Don't ask again") {
                    shouldAskForAppleMusicAuthorization = false
                    shouldConfirmSelection = false
                }
                Button("Not now", role: .cancel) {
                    shouldConfirmSelection = false
                }
            } message: {
                Text(
                    """
                    Physical needs Apple Music access to provide search results and pre-fill new \
                    additions. You do not need an active Apple Music subscription.
                    """
                )
            }
    }
    
    private func checkMusicAuthorization() async {
        guard !Task.isCancelled else { return }
        
        switch musicAuthorizationStatus {
        case .notDetermined:
            await requestMusicAuthorization()
            guard musicAuthorizationStatus != .notDetermined else { return }
            await checkMusicAuthorization()
        case .denied:
            guard shouldAskForAppleMusicAuthorization else { return }
            shouldConfirmSelection = true
        default:
            // Access authorized
            shouldConfirmSelection = false
        }
    }
    
    private func requestMusicAuthorization() async {
        let authorizationStatus = await MusicAuthorization.request()
        self.update(with: authorizationStatus)
    }
    
    @MainActor
    private func update(with musicAuthorizationStatus: MusicAuthorization.Status) {
        self.musicAuthorizationStatus = musicAuthorizationStatus
    }
}

extension View {
    func requestAppleMusicAccessIfNeeded() -> some View {
        modifier(MusicAuthorizationViewModifier())
    }
}
