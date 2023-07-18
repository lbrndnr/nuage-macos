//
//  MainView.swift
//  Nuage
//
//  Created by Laurin Brandner on 26.12.19.
//  Copyright © 2019 Laurin Brandner. All rights reserved.
//

import SwiftUI
import Combine
import AppKit
import URLImage
import Introspect
import StackNavigationView
import SoundCloud

struct MainView: View {
    
    @ObservedObject private var soundCloud = SoundCloud.shared
    
    @State private var navigationSelection: Int? = 0
    @State private var searchQuery = ""
    @State private var presentProfile = false
    
    @EnvironmentObject private var commands: Commands
    @EnvironmentObject private var player: StreamPlayer
    
    @State private var subscriptions = Set<AnyCancellable>()
    
    var body: some View {
        VStack(spacing: 0) {
            let stackItem: Binding<Int?> = Binding(get: { presentProfile ? 1 : (searchQuery.count > 0 ? 2 : nil) },
                                                      set: { value in
                                                        if value == nil {
                                                            presentProfile = false
                                                            searchQuery = ""
                                                        }
                                                      })
            
            StackNavigationView(selection: $navigationSelection, content: sidebar)
            .stack(item: stackItem) {
                if presentProfile {
                    UserDetail(user: SoundCloud.shared.user!)
                }
                else {
                    let search = SoundCloud.shared.get(.search(searchQuery))
                    SearchList(for: search)
                }
            }
            Divider()
            if player.queue.count > 0 {
                PlayerView()
            }
        }
        .frame(minWidth: 800, minHeight: 400)
        .toolbar(content: toolbar)
        .touchBar { TouchBar() }
    }
    
    @ViewBuilder private func sidebar() -> some View {
        let stream = SoundCloud.shared.get(.stream(), limit: 50)
        let streamView = PostList(for: stream).navigationTitle("Stream")
        
        let likes = SoundCloud.shared.$user.filter { $0 != nil}
            .flatMap { SoundCloud.shared.get(.trackLikes(of: $0!), limit: 50) }
            .eraseToAnyPublisher()
        let likesView = TrackList(for: likes).navigationTitle("Likes")
        
        let history = SoundCloud.shared.get(.history(), limit: 50)
        let historyView = TrackList(for: history).navigationTitle("History")
        
        let following = SoundCloud.shared.$user.filter { $0 != nil }
            .flatMap { SoundCloud.shared.get(.followings(of: $0!), limit: 50) }
            .eraseToAnyPublisher()
        let followingView = UserGrid(for: following).navigationTitle("Following")
        
        List {
            sidebarNavigationLink(title: "Stream", imageName: "bolt.horizontal.fill", destination: streamView, tag: 0)
            Section(header: Text("Library")) {
                sidebarNavigationLink(title: "Likes", imageName: "heart.fill", destination: likesView, tag: 1)
                sidebarNavigationLink(title: "History", imageName: "clock.fill", destination: historyView, tag: 2)
                sidebarNavigationLink(title: "Following", imageName: "person.2.fill", destination: followingView, tag: 3)
            }
            Section(header: Text("Playlists")) {
                let playlists = soundCloud.user?.playlists ?? []
                ForEach(Array(playlists.enumerated()), id: \.element.id) { idx, playlist in
                    let playlist = playlists[idx]

                    let ids = SoundCloud.shared.get(.playlist(playlist.id))
                        .map { $0.trackIDs ?? [] }
                        .eraseToAnyPublisher()
                    let slice = { ids in
                        return SoundCloud.shared.get(.tracks(ids))
                    }

                    let playlistView = TrackList(for: ids, slice: slice).navigationTitle(playlist.title)
                    SidebarNavigationLink(playlist.title, destination: playlistView, tag: idx+4, selection: $navigationSelection)
                }
            }
        }
        .listStyle(SidebarListStyle())
    }
    
    @ViewBuilder private func sidebarNavigationLink<V: View>(title: String, imageName: String, destination: V, tag: Int) -> some View {
        SidebarNavigationLink(destination: destination, tag: tag, selection: $navigationSelection) {
            HStack {
                Image(systemName: imageName)
                    .frame(width: 20, alignment: .center)
                Text(title)
            }
        }
    }
    
    @ViewBuilder fileprivate func toolbar() -> some View {
        TextField("􀊫 Search", text: $searchQuery)
            .onExitCommand { searchQuery = "" }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(minWidth: 150)
        Button(action: { presentProfile = true }) {
            RemoteImage(url: SoundCloud.shared.user?.avatarURL, cornerRadius: 15)
                .frame(width: 30, height: 30)
        }
        .buttonStyle(.plain)
    }
    
}

struct MainView_Previews: PreviewProvider {
    
    static var previews: some View {
        let player = StreamPlayer()
        player.enqueue(Preview.tracks)
        let mainView = MainView()
        
        return Group {
            mainView
            HStack {
                mainView.toolbar()
            }
            .previewDisplayName("Toolbar")
        }
        .environmentObject(player)
        .environmentObject(Commands())
    }
    
}
