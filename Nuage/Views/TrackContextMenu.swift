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
            Button("Like", action: toggleLike)
            Button("Repost", action: repost)
            Menu("Add to Playlist") {
                Button("New Playlist") {
                    print("new playlist lel")
                }

                if let playlists = SoundCloud.shared.user?.playlists,
                   playlists.count > 0 {
                    Divider()
                    ForEach(playlists) { playlist in
                        Button(playlist.title) {
//                            SoundCloud.shared.get(.addToPlaylist(playlist.id, trackIDs: [track.id]))
//                                .receive(on: RunLoop.main)
//                                .sink(receiveCompletion: { _ in
//                                }, receiveValue: { success in
//                                    print("added track to playlist")
//                                }).store(in: &subscriptions)
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
    
    private func toggleLike() {
        SoundCloud.shared.perform(.like(track))
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { success in
                print("liked track:", success)
            }).store(in: &subscriptions)
    }
    
    private func repost() {
        print("repost")
    }

}

extension View {
    
    func trackContextMenu(track: Track, onPlay: @escaping () -> ()) -> some View {
        return self.modifier(TrackContextMenu(track: track, onPlay: onPlay))
    }
    
}
