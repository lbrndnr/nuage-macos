//
//  SearchList.swift
//  Nuage
//
//  Created by Laurin Brandner on 25.12.20.
//

import SwiftUI
import Combine
import StackNavigationView
import SoundCloud

struct SearchList: View {
    
    var publisher: InfinitePublisher<Some>
    
    @EnvironmentObject private var player: StreamPlayer
    
    var body: some View {
        InfinteList(publisher: publisher) { elements, idx -> AnyView in
            let element = elements[idx]
            
            let onPlay = {
//                let tracks = elements.map(transform)
//                play(tracks, from: idx, on: player)
            }
            
            switch element {
            case .track(let track):
                return AnyView(StackNavigationLink(destination: TrackView(track: track)) {
                    TrackRow(track: track, onPlay: onPlay)
                }
                .trackContextMenu(track: track, onPlay: onPlay))
            case .playlist(let playlist):
                return AnyView(VStack(alignment: .leading) {
                    PlaylistRow(playlist: playlist, onPlay: onPlay)
                    Divider()
                })
            case .user(let user):
                return AnyView(UserRow(user: user))
            }
        }
        .navigationTitle("Search")
    }
    
    init(for publisher: AnyPublisher<Slice<Some>, Error>) {
        self.publisher = .slice(publisher)
    }
    
}
