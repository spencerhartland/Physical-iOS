//
//  FeaturedMediaView.swift
//  Physical
//
//  Created by Spencer Hartland on 8/18/23.
//

import SwiftUI
import MusicKit

struct FeaturedMediaView: View {
    private let demoAlbumArtURL = "https://static.wikia.nocookie.net/grimes/images/3/3e/I_Wanna_Be_Software_single_artwork.png/revision/latest/scale-to-width-down/1000?cb=20230705192807"
    private let featuredText = "Featured"
    
    private let favoriteSymbol = "star.circle.fill"
    private let placeholderSymbol = "music.note"
    private let playMediaSymbol = "play.fill"
    private let pauseMediaSymbol = "pause.fill"
    
    let title: String
    let artist: String
    
    private let musicPlayer = ApplicationMusicPlayer.shared
    @State private var playingMedia: Bool = false
    
    @Environment(\.screenSize) private var screenSize: CGSize
    
    var body: some View {
        let width = screenSize.width - 32
        let height = screenSize.height * 0.105
        
        return ZStack(alignment: .leading) {
            Color(UIColor.secondarySystemBackground)
                .cornerRadius(16)
            HStack {
                mediaImage(urlString: demoAlbumArtURL, height: height)
                VStack(alignment: .leading, spacing: 0) {
                    Text(featuredText.uppercased())
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.tertiary)
                        .padding(.bottom, 4)
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(1)
                    Text(artist)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                playbackControl
            }
        }
        .frame(width: width, height: height)
        .padding(.top, 24)
    }
    
    private var favoriteOrnament: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ZStack {
                    Circle()
                        .foregroundStyle(Color(UIColor.secondarySystemBackground))
                    Image(systemName: favoriteSymbol)
                        .resizable()
                        .foregroundStyle(.yellow)
                        .padding(4)
                }
                .frame(width: 28, height: 28)
            }
        }
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
                .font(.system(size: 28))
                .padding(24)
        }
    }
    
    private func mediaImage(urlString: String, height: CGFloat) -> some View {
        AsyncImage(url: URL(string: urlString)) { image in
            image
                .resizable()
        } placeholder: {
            mediaImagePlaceholder(height: height)
        }
        .frame(width: height - 32, height: height - 32)
        .cornerRadius(8)
        .padding([.top, .leading], 16)
        .padding([.bottom, .trailing], 8)
        .overlay {
            favoriteOrnament
        }
        .padding([.bottom, .trailing], 8)
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
    
    return FeaturedMediaView(title: "So heavy i fell through the earth (art mix)", artist: "Grimes")
        .environment(\.screenSize, screenSize)
}
