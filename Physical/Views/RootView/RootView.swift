//
//  RootView.swift
//  Physical
//
//  Created by Spencer Hartland on 8/24/23.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(NavigationManager.self) private var navigationManager
    @Environment(\.modelContext) private var modelContext
    
    // Widget
    @State private var widgetURLReceived = false
    @State private var requestedMedia: Media? = nil
    
    // Media addition
    @State private var draft = MediaDraft()
    @State private var mediaAdded: Bool = false
    @State private var shouldShowMediaAddedToast: Bool = false
    
    @State private var shouldHideStatusBar: Bool = false
    
    var body: some View {
        @Bindable var navigationManager = navigationManager
        
        NavigationStack(path: $navigationManager.path) {
            MediaCollectionView()
                .onOpenURL { url in
                    if let mediaID = UUID(uuidString: url.lastPathComponent) {
                        let fetchDesc = FetchDescriptor<Media>(
                            predicate: #Predicate { $0.id == mediaID }
                        )
                        if let result = try? modelContext.fetch(fetchDesc),
                           let media = result.first {
                            requestedMedia = media
                            widgetURLReceived = true
                        }
                    }
                }
                .navigationDestination(isPresented: $widgetURLReceived) {
                    if let requestedMedia { MediaDetailView(media: requestedMedia) }
                }
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
                            .onAppear { shouldHideStatusBar = true }
                            .onDisappear { shouldHideStatusBar = false }
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
                .onChange(of: navigationManager.path) { oldPath, newPath in
                    guard newPath.count < oldPath.count, !mediaAdded else { return }
                    
                    if let abortedStep = oldPath.last {
                        switch abortedStep {
                        case .detailEdit:
                            let title = draft.title
                            draft = MediaDraft()
                            draft.title = title
                        case .albumSearch:
                            draft = MediaDraft()
                        }
                    }
                }
        }
        .statusBarHidden(shouldHideStatusBar)
    }
}

#Preview {
    @Previewable @State var navigationManager = NavigationManager()
    
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let modelContainer = try! ModelContainer(for: Media.self, configurations: configuration)
    
    RootView()
        .modelContainer(modelContainer)
        .environment(navigationManager)
}
