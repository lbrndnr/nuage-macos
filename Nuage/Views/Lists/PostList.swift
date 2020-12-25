//
//  PostList.swift
//  Nuage
//
//  Created by Laurin Brandner on 20.12.20.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI
import SoundCloud

struct PostList: View {
    
    var publisher: InfinitePublisher<Post>
    
    @EnvironmentObject private var player: StreamPlayer
    
    var body: some View {
        InfinteList(publisher: publisher) { posts, idx -> AnyView in
            let post = posts[idx]
            
            let toggleLikeCurrentTrack = {
//                toggleLike(track)
            }
            let repostCurrentTrack = {
                print("reblog")
            }
            let onPlay = {
                let allTracks = posts.flatMap { $0.tracks }
                let trackCounts = posts.map { $0.tracks.count }
                let startIndex = trackCounts[0..<idx].reduce(0, +)
                play(allTracks, from: startIndex, on: player)
            }
            
            let action = post.isRepost ? "reposted" : "posted"
            return AnyView(VStack(alignment: .leading) {
                HStack(spacing: 10) {
                    WebImage(url: post.user.avatarURL)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .cornerRadius(15)
                    Text("\(post.user.username) \(action)")
                }
                Spacer()
                    .frame(height: 18)
                
                if case let .track(track) = post.item {
                    TrackRow(track: track, onLike: toggleLikeCurrentTrack, onReblog: repostCurrentTrack)
                }
                else if case let .playlist(playlist) = post.item {
                    PlaylistRow(playlist: playlist, onLike: toggleLikeCurrentTrack, onReblog: repostCurrentTrack)
                }
                
                Divider()
            }
            .onTapGesture(count: 2, perform: onPlay))
//            .trackContextMenu(track: track, onPlay: play))
        }
    }
    
    init(for publisher: AnyPublisher<Slice<Post>, Error>) {
        self.publisher = .slice(publisher)
    }

}
