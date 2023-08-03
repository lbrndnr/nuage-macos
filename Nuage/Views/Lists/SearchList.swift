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
        InfiniteList(publisher: publisher) { elem in
            switch elem {
            case .track(let track):
                TrackRow(track: track)
                    .trackContextMenu(with: track)
            case .userPlaylist(let playlist):
                PlaylistRow(playlist: playlist)
            case .systemPlaylist(let playlist):
                PlaylistRow(playlist: playlist)
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
