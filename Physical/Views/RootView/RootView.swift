//
//  RootView.swift
//  Physical
//
//  Created by Spencer Hartland on 8/24/23.
//

import SwiftUI
import SwiftData

struct RootView: View {
    // Navigation
    @State private var navigationManager = NavigationManager()
    
    // Media addition
    @State private var draft = MediaDraft()
    @State private var mediaAdded: Bool = false
    @State private var shouldShowMediaAddedToast: Bool = false
    
    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            MediaCollectionView()
                .environment(\.navigationManager, navigationManager)
                .navigationDestination(for: MediaEntryStep.self) { step in
                    @Bindable var draft = self.draft
                    
                    Group {
                        switch step {
                        case .albumSearch(.manual):
                            AddMediaView(draft: $draft) {
                                navigationManager.path.append(MediaEntryStep.detailEdit)
                            }
                        case .albumSearch(.barcode):
                            BarcodeScanAlbumSearchView(draft: $draft) { albumDetected in
                                if albumDetected {
                                    navigationManager.path.append(MediaEntryStep.detailEdit)
                                } else {
                                    navigationManager.path.append(MediaEntryStep.albumSearch(.manual))
                                }
                            }
                        case .detailEdit:
                            MediaDetailsEntryView(draft: $draft, mediaAdded: $mediaAdded) {
                                let steps = navigationManager.path.count - 1
                                if steps > 1 {
                                    navigationManager.path.removeLast()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        navigationManager.path.removeLast()
                                    }
                                } else {
                                    navigationManager.path.removeLast()
                                }
                            }
                        }
                    }
                    .mediaAddedToast(isPresented: $shouldShowMediaAddedToast)
                    .sensoryFeedback(trigger: shouldShowMediaAddedToast) {
                        shouldShowMediaAddedToast ? .success : nil
                    }
                }
                .onChange(of: mediaAdded) {
                    guard mediaAdded else { return }
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(0.6))
                        self.draft = MediaDraft()
                        
                        try? await Task.sleep(for: .seconds(0.05))
                        withAnimation { shouldShowMediaAddedToast = true }
                        
                        try? await Task.sleep(for: .seconds(2.35))
                        mediaAdded = false
                    }
                }
        }
    }
}
