//
//  PostList.swift
//  Nuage
//
//  Created by Laurin Brandner on 20.12.20.
//

import SwiftUI
import Combine
import SoundCloud

struct PostList: View {
    
    var publisher: InfinitePublisher<Post>
    
    @EnvironmentObject private var player: StreamPlayer
    
    var body: some View {
        InfiniteList(publisher: publisher) { posts, idx -> AnyView in
            let post = posts[idx]
            let onPlay = {
                let allTracks = posts.flatMap { $0.tracks }
                let trackCounts = posts.map { $0.tracks.count }
                let startIndex = trackCounts[0..<idx].reduce(0, +)
                play(allTracks, from: startIndex, on: player)
            }
            
            return AnyView(
                VStack(alignment: .leading) {
                    PostRow(post: post, onPlay: onPlay)
                    Divider()
                }
            )
        }
    }
    
    init(for publisher: AnyPublisher<Slice<Post>, Error>) {
        self.publisher = .slice(publisher)
    }

}
