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
    let thumbnailWidth: CGFloat?
    let steppedScrolling: Bool
    
    @Environment(\.screenSize) private var screenSize: CGSize
    
    init(
        _ title: String,
        content: [Media],
        thumbnailWidth: CGFloat? = nil,
        steppedScrolling: Bool = false
    ) {
        self.title = title
        self.content = content
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
                            MediaThumbnail(for: content[index])
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
    @Previewable @State var screenSize: CGSize = {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        return window.screen.bounds.size
    }()
    
    return CollectionSection("Favorites", content: [])
        .environment(\.screenSize, screenSize)
}
