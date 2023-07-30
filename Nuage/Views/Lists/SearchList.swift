//
//  SearchList.swift
//  Nuage
//
//  Created by Laurin Brandner on 25.12.20.
//

import SwiftUI
import Combine
import SoundCloud

struct SearchList: View {
    
    private var publisher: InfinitePublisher<Some>
    
    @EnvironmentObject private var player: StreamPlayer
    
    var body: some View {
        InfiniteList(publisher: publisher) { elements, idx in
            let element = elements[idx]

            let onPlay = {
//                let tracks = elements.map(transform)
//                play(tracks, from: idx, on: player)
            }

            switch element {
            case .track(let track):
                TrackRow(track: track, onPlay: onPlay)
                    .trackContextMenu(track: track, onPlay: onPlay)
            case .userPlaylist(let playlist):
                PlaylistRow(playlist: playlist, onPlay: onPlay)
            case .systemPlaylist(let playlist):
                PlaylistRow(playlist: playlist, onPlay: onPlay)
            case .user(let user):
                UserItem(user: user)
            }
            Divider()
        }
        .navigationTitle("Search")
    }
    
    init(for publisher: AnyPublisher<Slice<Some>, Error>) {
        self.publisher = .slice(publisher)
    }
    
}
