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

struct TrackContextMenu: ViewModifier {
    
    @ObservedObject private var soundCloud = SoundCloud.shared
    
    @EnvironmentObject private var player: StreamPlayer
    @State private var subscriptions = Set<AnyCancellable>()
    
    private var track: Track
    private var onPlay: () -> ()
    
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

                let playlists = (soundCloud.user?.playlists ?? [])
                    .compactMap { $0.userPlaylist }
                    .filter { $0.secretToken != nil }
                if playlists.count > 0 {
                    Divider()
                    ForEach(playlists, id: \.id) { playlist in
                        Button(playlist.title) {
                            SoundCloud.shared.get(.add(to: playlist, trackIDs: [track.id]))
                                .receive(on: RunLoop.main)
                                .sink(receiveCompletion: { _ in
                                }, receiveValue: { success in
                                    print("added track to playlist")
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
    
    init(track: Track, onPlay: @escaping () -> ()) {
        self.track = track
        self.onPlay = onPlay
    }

}

extension View {
    
    func trackContextMenu(track: Track, onPlay: @escaping () -> ()) -> some View {
        return modifier(TrackContextMenu(track: track, onPlay: onPlay))
    }
    
}
