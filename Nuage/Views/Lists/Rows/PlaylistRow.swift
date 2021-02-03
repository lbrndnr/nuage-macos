//
//  PlaylistRow.swift
//  Nuage
//
//  Created by Laurin Brandner on 25.12.20.
//

import SwiftUI
import StackNavigationView
import SoundCloud

struct PlaylistRow: View {
    
    private var playlist: Playlist
    private var onLike: () -> ()
    private var onReblog: () -> ()
    
    init(playlist: Playlist, onLike: @escaping () -> (), onReblog: @escaping () -> ()) {
        self.playlist = playlist
        self.onLike = onLike
        self.onReblog = onReblog
    }
    
    var body: some View {
        let artworkURL = playlist.artworkURL ?? playlist.tracks?.first?.artworkURL
        
        return HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading) {
                Artwork(url: playlist.artworkURL) { }
                    .frame(width: 100, height: 100)
                Spacer()
                HStack {
                    Button(action: onLike) {
                        Image(systemName: "heart")
                    }.buttonStyle(BorderlessButtonStyle())
                    Button(action: onReblog) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }.buttonStyle(BorderlessButtonStyle())
                }
            }
            VStack(alignment: .leading) {
                Text(playlist.title)
                    .font(.title3)
                    .bold()
                    .lineLimit(1)
                StackNavigationLink(playlist.user.displayName, destination: UserView(user: playlist.user))
                    .buttonStyle(PlainButtonStyle())
                
                Spacer()
                    .frame(height: 8)

                if let description = playlist.description {
                    let text = description.trimmingCharacters(in: .whitespacesAndNewlines)
                        .replacingOccurrences(of: "\n", with: " ")
                    Text(text).lineLimit(3)
                }
                
                if let tracks = playlist.tracks {
                    Divider()
                    ForEach(tracks, id: \.self) { track in
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
        .padding(6)
    }

}

extension PlaylistRow: Equatable {

    static func == (lhs: PlaylistRow, rhs: PlaylistRow) -> Bool {
        return lhs.playlist == rhs.playlist
    }


}
