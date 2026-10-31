//
//  CollectionArrangementView.swift
//  Physical
//
//  Created by Spencer Hartland on 10/31/26.
//

import SwiftUI

@available(anyAppleOS 27.1, *)
struct CollectionArrangementView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var selection: Media?
    
    var body: some View {
        GeometryReader { proxy in
            let aspectRatio = proxy.size.height / proxy.size.width
            var shouldDisplayNavigationLink: Bool {
                horizontalSizeClass == .compact || aspectRatio > 1
            }
            
            ArrangementView {
                MediaCollectionView(
                    showsDetailsLink: shouldDisplayNavigationLink
                ) { media in
                    selection = media
                }
            } secondary: {
                if let selection {
                    MediaDetailView(for: selection, allowsNavigationBackwards: false)
                } else {
                    ContentUnavailableView(
                        "No Selection",
                        systemImage: "music.note.slash",
                        description: Text("Select an item from your collection.")
                    )
                }
            }
            .arrangementViewStyle(.split.axes(.horizontal))
        }
    }
}
