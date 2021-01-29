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
            
            let toggleLikeCurrentTrack = {
//                toggleLike(track)
            }
            let repostCurrentTrack = {
//                onRepost(track)
            }
            
            switch element {
            case .track(let track):
                return AnyView(StackNavigationLink(destination: TrackView(track: track)) {
                    TrackRow(track: track, onLike: toggleLikeCurrentTrack, onReblog: repostCurrentTrack)
                        .onTapGesture(count: 2, perform: onPlay)
                }
                .trackContextMenu(track: track, onPlay: onPlay))
            case .playlist(let playlist):
                return AnyView(VStack(alignment: .leading) {
                    PlaylistRow(playlist: playlist, onLike: toggleLikeCurrentTrack, onReblog: repostCurrentTrack)
                    Divider()
                }
                .onTapGesture(count: 2, perform: onPlay))
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
