//
//  PostRow.swift
//  Nuage
//
//  Created by Laurin Brandner on 26.07.23.
//

import SwiftUI
import Combine
import SoundCloud
import StackNavigationView

struct PostRow: View {
    
    private var post: Post
    private var onPlay: () -> ()
    
    @State private var subscriptions = Set<AnyCancellable>()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 10) {
                StackNavigationLink(destination: UserDetail(user: post.user)) {
                    RemoteImage(url: post.user.avatarURL, cornerRadius: 15)
                        .frame(width: 30, height: 30)
                    
                    let title: AttributedString = {
                        var attributes = AttributeContainer()
                        attributes.font = .body.bold()
                        let username = AttributedString(post.user.username, attributes: attributes)
                        
                        let action = post.isRepost ? " reposted" : " posted"
                        return username + AttributedString(action)
                    }()
                    
                    Text(title)
                }
            }
            Spacer()
                .frame(height: 18)
            
            if case let .track(track) = post.item {
                StackNavigationLink(destination: TrackDetail(track: track)) {
                    TrackRow(track: track, onPlay: onPlay)
                }
                .trackContextMenu(track: track, onPlay: onPlay)
            }
            else if case let .playlist(playlist) = post.item {
                PlaylistRow(playlist: playlist, onPlay: onPlay)
                    .onTapGesture(count: 2, perform: onPlay)
            }
        }
    }
        
        
    init(post: Post, onPlay: @escaping () -> ()) {
        self.post = post
        self.onPlay = onPlay
    }
    
}

