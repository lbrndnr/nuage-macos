//
//  PlaylistRow.swift
//  Nuage
//
//  Created by Laurin Brandner on 25.12.20.
//

import SwiftUI
import SoundCloud

struct PlaylistRow<T: Playlist>: View {
    
    private var playlist: T
    private var onPlay: () -> ()
    
    init(playlist: T, onPlay: @escaping () -> ()) {
        self.playlist = playlist
        self.onPlay = onPlay
    }
    
    var body: some View {
        let artworkURL = playlist.artworkURL ?? playlist.tracks?.first?.artworkURL
        
        return HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading) {
                Artwork(url: artworkURL, onPlay: onPlay)
                    .frame(width: 100, height: 100)
                Spacer()
                FeedbackStack(for: playlist)
                Spacer()
            }
            VStack(alignment: .leading) {
                Text(playlist.title)
                    .font(.title3)
                    .bold()
                    .lineLimit(1)
                RowNavigationLink(playlist.user.displayName, value: playlist.user)
                Spacer()
                    .frame(height: 8)

                if let description = playlist.description {
                    let text = description.trimmingCharacters(in: .whitespacesAndNewlines)
                        .replacingOccurrences(of: "\n", with: " ")
                    Text(text).lineLimit(3)
                }
                
                if let tracks = playlist.tracks {
                    Divider()
                    ForEach(tracks, id: \.id) { track in
                        HStack {
                            Text(track.title)
                            Image(systemName: "play.fill")
                            Text(String(track.playbackCount))
                            Image(systemName: "heart.fill")
                            Text(String(track.likeCount))
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text(String(track.repostCount))
                        }.foregroundColor(Color(NSColor.secondaryLabelColor))
                        Divider()
                    }
                }
            }
        }
    }

}
