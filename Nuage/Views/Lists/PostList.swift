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
    
    private var publisher: InfinitePublisher<Post>
    
    @EnvironmentObject private var player: StreamPlayer
    
    var body: some View {
        InfiniteList(publisher: publisher) { posts, idx in
            PostRow(post: posts[idx])
                .playbackStart(at: posts[idx])
        }
    }
    
    init(for publisher: AnyPublisher<Slice<Post>, Error>) {
        self.publisher = .slice(publisher)
    }

}
