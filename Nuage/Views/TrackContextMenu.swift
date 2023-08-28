//
//  TrackContextMenu.swift
//  Nuage
//
//  Created by Laurin Brandner on 04.12.20.
//  Copyright © 2020 Laurin Brandner. All rights reserved.
//

import SwiftUI
import Combine
import SoundCloud

private struct TrackContextMenu: ViewModifier {
    
    @ObservedObject private var soundCloud = SoundCloud.shared
    
    var track: Track
    
    @State private var subscriptions = Set<AnyCancellable>()
    
    @EnvironmentObject private var player: StreamPlayer
    @Environment(\.playlists) private var playlists: [AnyPlaylist]
    @Environment(\.toggleLikeTrack) private var toggleLike: (Track) -> () -> ()
    @Environment(\.toggleRepostTrack) private var toggleRepost: (Track) -> () -> ()
    @Environment(\.onPlay) private var onPlay: () -> ()
    
    func body(content: Content) -> some View {
        content.contextMenu {
            Button("Play", action: onPlay)
            Button("Add to Queue") {
                player.enqueue([track])
            }
            Divider()
            Button("Go to User") {
                print("haha")
            }
            Divider()
            Button("Like", action: toggleLike(track))
            Button("Repost", action: toggleRepost(track))
            Menu("Add to Playlist") {
                Button("New Playlist") {
                    print("new playlist lel")
                }

                let playlists = playlists
                    .compactMap { $0.userPlaylist }
                    .filter { $0.secretToken != nil }
                if playlists.count > 0 {
                    Divider()
                    ForEach(playlists, id: \.id) { playlist in
                        Button(playlist.title) {
                            let newTrackID = Int(track.id)!
                            
                            soundCloud.get(.userPlaylist(playlist.id))
                                .map { ($0.trackIDs ?? []).map { Int($0)! } }
                                .flatMap { soundCloud.get(.set(playlist, trackIDs: $0 + [newTrackID])) }
                                .receive(on: RunLoop.main)
                                .sink(receiveCompletion: { _ in
                                }, receiveValue: { success in
                                    print("added track to playlist: \(success)")
                                }).store(in: &subscriptions)
                        }
                    }
                }
            }
            Divider()
            Button("Copy Link") {
                let text = track.permalinkURL.absoluteString
                NSPasteboard.general.declareTypes([.string], owner: nil)
                NSPasteboard.general.setString(text, forType: .string)
            }
        }
    }

}

extension View {
    
    func trackContextMenu(with track: Track) -> some View {
        return modifier(TrackContextMenu(track: track))
    }
    
}
