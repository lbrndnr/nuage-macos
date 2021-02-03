//
//  PostList.swift
//  Nuage
//
//  Created by Laurin Brandner on 20.12.20.
//

import SwiftUI
import Combine
import StackNavigationView
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
                    StackNavigationLink(destination: UserView(user: post.user)) {
                        RemoteImage(url: post.user.avatarURL, cornerRadius: 15)
                            .frame(width: 30, height: 30)
                        Text("\(post.user.username) \(action)")
                    }
                }
                Spacer()
                    .frame(height: 18)

                if case let .track(track) = post.item {
                    StackNavigationLink(destination: TrackView(track: track)) {
                        TrackRow(track: track, onLike: toggleLikeCurrentTrack, onReblog: repostCurrentTrack)
                            .onTapGesture(count: 2, perform: onPlay)
                    }
                    .trackContextMenu(track: track, onPlay: onPlay)
                }
                else if case let .playlist(playlist) = post.item {
                    PlaylistRow(playlist: playlist, onLike: toggleLikeCurrentTrack, onReblog: repostCurrentTrack)
                        .onTapGesture(count: 2, perform: onPlay)
                }

                Divider()
            })
        }
    }
    
    init(for publisher: AnyPublisher<Slice<Post>, Error>) {
        self.publisher = .slice(publisher)
    }

}
