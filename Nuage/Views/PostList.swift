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
    
    var publisher: AnyPublisher<Slice<Post>, Error>
    
    @EnvironmentObject private var player: StreamPlayer
    @State private var subscriptions = Set<AnyCancellable>()
    
    var body: some View {
        SliceList(publisher: publisher) { posts, idx -> AnyView in
            let post = posts[idx]
            let tracks = post.tracks
            guard let track = tracks.first else { return AnyView(EmptyView()) }
            
            let toggleLikeCurrentTrack = {
                self.toggleLike(track)
            }
            let repostCurrentTrack = {
                print("reblog")
            }
            let play = {
    //            self.play(tracks, from: idx)
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
            .onTapGesture(count: 2, perform: play)
            .trackContextMenu(track: track, onPlay: play))
        }
    }
    
    init(publisher: AnyPublisher<Slice<Post>, Error>) {
        self.publisher = publisher
    }
    
    private func toggleLike(_ track: Track)  {
        SoundCloud.shared.perform(.like(track))
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { success in
                print("liked track:", success)
            }).store(in: &subscriptions)
    }

    private func play(_ tracks: [Track], from idx: Int) {
        player.reset()
        player.enqueue(tracks)
        player.resume(from: idx)
    }

}

struct PlaylistRow: View {
    
    private var playlist: Playlist
    private var onLike: () -> ()
    private var onReblog: () -> ()
    
    init(playlist: Playlist, onLike: @escaping () -> (), onReblog: @escaping () -> ()) {
        self.playlist = playlist
        self.onLike = onLike
        self.onReblog = onReblog
    }
    
    var body: some View {
        return HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading) {
                WebImage(url: playlist.artworkURL)
                    .resizable()
                    .placeholder { Rectangle().foregroundColor(.gray) }
                    .frame(width: 100, height: 100)
                    .cornerRadius(6)
                Spacer()
                HStack {
                    Button(action: onLike) {
                        Image(systemName: "heart")
                    }.buttonStyle(BorderlessButtonStyle())
                    Button(action: onReblog) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }.buttonStyle(BorderlessButtonStyle())
                }
            }
            VStack(alignment: .leading) {
                Text(playlist.title)
                    .font(.title3)
                    .bold()
                Spacer()
                    .frame(height: 8)

                if let description = playlist.description {
                    let text = description.trimmingCharacters(in: .whitespacesAndNewlines)
                        .replacingOccurrences(of: "\n", with: " ")
                    Text(text)
                }
                
                if case let Tracks.full(tracks) = playlist.tracks {
                    Divider()
                    ForEach(tracks, id: \.self) { track in
                        HStack {
                            Text(track.title)
                            Image(systemName: "play.fill")
                            Text(String(track.playbackCount))
                            Image(systemName: "heart.fill")
                            Text(String(track.likeCount))
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text(String(track.repostCount))
                        }.foregroundColor(Color(NSColor.secondaryLabelColor))
                        Divider()
                    }
                }
            }
        }
        .padding(6)
    }

    
}
