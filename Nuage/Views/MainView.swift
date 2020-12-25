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
import SoundCloud

struct MainView: View {
    
    @State private var navigationSelection: Int? = 0
    @State private var playlists = [Playlist]()
    @State private var searchQuery = ""
    @State private var subscriptions = Set<AnyCancellable>()
    
    var body: some View {
        let stream = SoundCloud.shared.get(.stream())
        let history = SoundCloud.shared.get(.history())
        let likes = SoundCloud.shared.$user.filter { $0 != nil}
            .flatMap { SoundCloud.shared.get(.trackLikes(of: $0!)) }
            .map { $0}
            .eraseToAnyPublisher()
        
        return VStack {
            NavigationView {
                List {
                    NavigationLink("Stream", destination: PostList(for: stream), tag: 0, selection: $navigationSelection)
                    Section(header: Text("Library")) {
                        NavigationLink("Likes", destination: TrackList(for: likes), tag: 1, selection: $navigationSelection)
                        NavigationLink("History", destination: TrackList(for: history), tag: 2, selection: $navigationSelection)
                        NavigationLink("Following", destination: UserList(), tag: 3, selection: $navigationSelection)
                    }
                    Section(header: Text("Playlists")) {
                        ForEach(0..<playlists.count, id: \.self) { idx in
                            let playlist = playlists[idx]
                            let ids = SoundCloud.shared.get(.playlist(playlist.id))
                                .map { $0.trackIDs ?? [] }
                                .eraseToAnyPublisher()
                            let slice = { ids in
                                return SoundCloud.shared.get(.tracks(ids))
                            }

                            let playlistView = TrackList(for: ids, slice: slice)
                            NavigationLink(playlist.title, destination: playlistView, tag: idx+4, selection: $navigationSelection)
                        }
                    }
                }
                .listStyle(SidebarListStyle())
                if searchQuery.count > 0 {
                    let search = SoundCloud.shared.get(.search(searchQuery))
                    SearchList(for: search)
                }
            }
            PlayerView()
        }
        .frame(minWidth: 800, minHeight: 400)
        .toolbar {
            ToolbarItem {
                TextField("Search", text: $searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minWidth: 150)
            }
            ToolbarItem {
                HStack {
                    Text(SoundCloud.shared.user?.username ?? "Profile")
                        .bold()
//                    WebImage(url: SoundCloud.shared.user?.avatarURL)
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                        .cornerRadius(15)
                }
            }
        }
        .onAppear {            
            SoundCloud.shared.get(.albumsAndPlaylists())
                .map { $0.collection }
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
