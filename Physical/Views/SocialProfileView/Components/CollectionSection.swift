//
//  CollectionSection.swift
//  Physical
//
//  Created by Spencer Hartland on 8/24/23.
//

import SwiftUI

struct CollectionSection: View {
    let title: String
    let content: [Media]
    let thumbnailsOrnamented: Bool
    let thumbnailWidth: CGFloat?
    let steppedScrolling: Bool
    
    @Environment(\.screenSize) private var screenSize: CGSize
    
    init(
        _ title: String,
        content: [Media],
        thumbnailsOrnamented: Bool = true,
        thumbnailWidth: CGFloat? = nil,
        steppedScrolling: Bool = false
    ) {
        self.title = title
        self.content = content
        self.thumbnailsOrnamented = thumbnailsOrnamented
        self.thumbnailWidth = thumbnailWidth
        self.steppedScrolling = steppedScrolling
    }
    
    var body: some View {
        let mediaThumbnailWidth = thumbnailWidth ?? (screenSize.width / 2) - 24
        
        return VStack(alignment: .leading) {
            // Profile section title
            Text(title)
                .padding([.top, .leading])
                .font(.title2.weight(.semibold))
            
            // Media carousel
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: steppedScrolling ? 16 : 8) {
                    ForEach(0..<5) { index in
                        if index < content.count {
                            MediaThumbnail(for: content[index], ornamented: thumbnailsOrnamented)
                                .frame(width: mediaThumbnailWidth)
                                .padding(.top, 4)
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .safeAreaPadding(.horizontal)
            .steppedScrollBehavior(steppedScrolling)
        }
    }
}

// View extension to optionally enable stepped scrolling for profile sections
fileprivate extension View {
    @ViewBuilder func steppedScrollBehavior(_ enabled: Bool) -> some View {
        if enabled {
            self
                .scrollTargetBehavior(.viewAligned)
        } else {
            self
        }
    }
}

#Preview {
    @State var screenSize: CGSize = {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        return window.screen.bounds.size
    }()
    
    return CollectionSection("Favorites", content: [])
        .environment(\.screenSize, screenSize)
}
