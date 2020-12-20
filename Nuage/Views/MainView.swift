//
//  MainView.swift
//  Nuage
//
//  Created by Laurin Brandner on 26.12.19.
//  Copyright © 2019 Laurin Brandner. All rights reserved.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI

struct MainView: View {
    
    @State private var playlists = [Playlist]()
    
    @State private var subscriptions = Set<AnyCancellable>()
    
    var body: some View {
        let stream = SoundCloud.shared.get(.stream())
            .eraseToAnyPublisher()
//            .map { $0.sorted { $0.date > $1.date }
//                .compactMap { post -> Track? in
//                    switch post.kind {
//                    case .track(let track): return track
//                    case .trackRepost(let track): return track
//                    default: return nil
//                    }
//                }}
//            .eraseToAnyPublisher()
        
        let history = SoundCloud.shared.get(.history())
//            .map { $0.sorted { $0.date > $1.date }
//                     .map { $0.track }}
//            .eraseToAnyPublisher()
        
        let likes = SoundCloud.shared.$user.filter { $0 != nil}
            .flatMap { SoundCloud.shared.get(.trackLikes(of: $0!)) }
            .map { $0}
            .eraseToAnyPublisher()
//            .map { $0.sorted { $0.date > $1.date }
//                     .map { $0.item }}
//            .eraseToAnyPublisher()
        
        let streamView = PostList(publisher: stream)
        
        return VStack {
            NavigationView {
                List {
                    NavigationLink(destination: streamView) { Text("Stream") }
                    Section(header: Text("Library")) {
                        NavigationLink(destination: TrackList(publisher: likes)) { Text("Likes") }
                        NavigationLink(destination: TrackList(publisher: history)) { Text("History") }
                        NavigationLink(destination: UserList()) { Text("Following") }
                    }
                    Section(header: Text("Playlists")) {
//                        List(playlists) { playlist in
//                            let tracks = SoundCloud.shared.get(.playlist(playlist.id))
//                                .flatMap { playlist -> AnyPublisher<Slice<Track>, Error> in
//                                    let ids = Array(playlist.trackIDs!.prefix(16))
//                                    return SoundCloud.shared.get(.tracks(ids))
//                                        .map { Slice(collection: $0, next: nil) }
//                                        .eraseToAnyPublisher()
//                                }
//                                .eraseToAnyPublisher()
//
//                            NavigationLink(destination:  TrackList(publisher: tracks)) { Text(playlist.title) }
//                        }
                    }
                }
                .listStyle(SidebarListStyle())
                .frame(minWidth: 100)
                streamView
            }
            PlayerView()
        }
        .frame(minWidth: 400, minHeight: 400)
//        .toolbar {
//            ToolbarItem {
//                HStack {
//                    Text(SoundCloud.shared.user?.username ?? " ")
//                        .bold()
//                    WebImage(url: SoundCloud.shared.user?.avatarURL)
//                        .frame(width: 30, height: 30)
//                        .cornerRadius(15)
//                }
//            }
//        }
        .onAppear {            
            SoundCloud.shared.get(.albumsAndPlaylists())
                .map { $0.collection }
                .eraseToAnyPublisher()
                .replaceError(with: [])
                .receive(on: RunLoop.main)
                .sink { likes in
                    let playlists = likes.map { $0.item }
                    self.playlists = playlists
                    SoundCloud.shared.user?.playlists = playlists
                }
                .store(in: &self.subscriptions)
        }
    }
    
}

//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}
