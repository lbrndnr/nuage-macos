//
//  TrackContextMenu.swift
//  Nuage
//
//  Created by Laurin Brandner on 04.12.20.
//  Copyright © 2020 Laurin Brandner. All rights reserved.
//

import SwiftUI
import Combine

struct TrackContextMenu: ViewModifier {
    
    private var player: StreamPlayer
    private var tracks: [Track]
    private var track: Track {
        return tracks[idx]
    }
    
    private var idx: Int
    @State private var subscriptions = Set<AnyCancellable>()
    
    func body(content: Content) -> some View {
        content.contextMenu {
            Button("Play") {
                self.player.reset()
                self.player.enqueue(tracks)
                self.player.resume(from: idx)
            }
            Button("Add to Queue") {
                self.player.enqueue([track])
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
    
    init(idx: Int, tracks: [Track], player: StreamPlayer) {
        self.idx = idx
        self.tracks = tracks
        self.player = player
    }
    
    private func toggleLike() {
        SoundCloud.shared.perform(.likeTrack(track.id))
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
    
    func trackContextMenu(idx: Int, tracks: [Track], player: StreamPlayer) -> some View {
        return self.modifier(TrackContextMenu(idx: idx, tracks: tracks, player: player))
    }
    
}
