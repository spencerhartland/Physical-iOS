//
//  CompactMediaView.swift
//  Physical
//
//  Created by Spencer Hartland on 8/27/23.
//

import SwiftUI
import MusicKit

struct CompactMediaView: View {
    private let demoAlbumArtURL = "https://static.wikia.nocookie.net/grimes/images/3/3e/I_Wanna_Be_Software_single_artwork.png/revision/latest/scale-to-width-down/1000?cb=20230705192807"
    
    private let favoriteSymbol = "star.circle.fill"
    private let placeholderSymbol = "music.note"
    private let playMediaSymbol = "play.fill"
    private let pauseMediaSymbol = "pause.fill"
    
    let title: String
    let artist: String
    let enabled: Bool
    
    private let musicPlayer = ApplicationMusicPlayer.shared
    @State private var playingMedia: Bool = false
    
    @Environment(\.screenSize) private var screenSize: CGSize
    
    init(title: String, artist: String, enabled: Bool = true) {
        self.title = title
        self.artist = artist
        self.enabled = enabled
    }
    
    var body: some View {
        let height = screenSize.height * 0.065
        
        return ZStack(alignment: .leading) {
            if enabled {
                Color(UIColor.secondarySystemBackground)
                    .cornerRadius(12)
            }
            HStack {
                mediaImage(urlString: demoAlbumArtURL, height: height)
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(1)
                    Text(artist)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                if enabled {
                    playbackControl
                }
            }
        }
        .frame(height: height)
    }
    
    private var playbackControl: some View {
        Button {
            if playingMedia {
                playingMedia = false
                musicPlayer.pause()
            } else if musicPlayer.isPreparedToPlay {
                playingMedia = true
                Task {
                    do {
                        try await musicPlayer.play()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        } label: {
            Image(systemName: playingMedia ? pauseMediaSymbol : playMediaSymbol)
                .font(.system(size: 24))
                .padding(.trailing)
        }
    }
    
    private func mediaImage(urlString: String, height: CGFloat) -> some View {
        AsyncImage(url: URL(string: urlString)) { image in
            image
                .resizable()
        } placeholder: {
            mediaImagePlaceholder(height: height)
        }
        .frame(width: height - 8, height: height - 8)
        .cornerRadius(8)
        .padding(4)
    }
    
    private func mediaImagePlaceholder(height: CGFloat) -> some View {
        Color(UIColor.systemBackground)
            .overlay {
                Image(systemName: placeholderSymbol)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(height * 0.1)
                    .foregroundStyle(Color(UIColor.secondarySystemBackground))
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
    
    return CompactMediaView(title: "I Wanna Be Software", artist: "Grimes")
        .environment(\.screenSize, screenSize)
        .padding(.horizontal)
}
