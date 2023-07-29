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
import SoundCloud

struct MainView: View {
    
    @ObservedObject private var soundCloud = SoundCloud.shared
    
    @State private var sidebarSelection: SidebarItem = .stream
    @State private var navigationPath = NavigationPath()
    @State private var blockingNavigationPath: NavigationPath?
    
    @State private var searchQuery = ""
    @State private var subscriptions = Set<AnyCancellable>()
    
    @EnvironmentObject private var commands: Commands
    @EnvironmentObject private var player: StreamPlayer
    @Environment(\.playlists) private var playlists: [AnyPlaylist]
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationSplitView(sidebar: sidebar) {
                NavigationStack(path: $navigationPath) {
                    root(for: sidebarSelection)
                        .navigationDestination(for: Track.self) { TrackDetail(track: $0) }
                        .navigationDestination(for: User.self) { UserDetail(user: $0) }
                    }
            }
            Divider()
            if player.queue.count > 0 {
                PlayerView {
                    if let track = player.currentStream, navigationPath != blockingNavigationPath {
                        navigationPath.append(track)
                        blockingNavigationPath = navigationPath
                    }
                }
            }
        }
        .frame(minWidth: 800, minHeight: 400)
        .toolbar(content: toolbar)
        .touchBar { TouchBar() }
        .onOpenURL { url in
            guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
            
            components.scheme = "https"
            guard let newURL = components.url else { return }
            
            soundCloud.get(.resolve(newURL))
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    if case let .failure(error) = completion  {
                        print("Failed to resolve url: \(error)")
                    }
                }, receiveValue: { elem in
                    switch elem {
                    case .track(let track): navigationPath.append(track)
                    case .user(let user): navigationPath.append(user)
                    default: print("Not implemented.")
                    }
                })
                .store(in: &subscriptions)
        }
        .handlesExternalEvents(preferring: ["*"], allowing: ["*"])
    }
    
    @ViewBuilder private func sidebar() -> some View {
        List(selection: $sidebarSelection) {
            sidebarMenu(for: .stream)
            sidebarMenu(for: .likes)
            sidebarMenu(for: .history)
            sidebarMenu(for: .following)
            
            Section(header: Text("Playlists")) {
                ForEach(playlists) { playlist in
                    sidebarMenu(for: .playlist(playlist.title, playlist.id))
                }
            }
        }
    }
    
    @ViewBuilder private func sidebarMenu(for detail: SidebarItem) -> some View {
        NavigationLink(value: detail) {
            HStack {
                if let imageName = detail.imageName {
                    Image(systemName: imageName)
                        .frame(width: 20, alignment: .center)
                }
                Text(detail.title)
            }
        }
    }
    
    @ViewBuilder private func root(for item: SidebarItem) -> some View {
        switch item {
        case .stream:
            let stream = SoundCloud.shared.get(.stream())
            PostList(for: stream).navigationTitle(item.title)
        case .likes:
            let likes = SoundCloud.shared.$user.filter { $0 != nil}
                .flatMap { SoundCloud.shared.get(.trackLikes(of: $0!)) }
                .eraseToAnyPublisher()
            TrackList(for: likes).navigationTitle(item.title)
        case .history:
            let history = SoundCloud.shared.get(.history())
            TrackList(for: history).navigationTitle(item.title)
        case .following:
            let following = SoundCloud.shared.$user.filter { $0 != nil }
                .flatMap { SoundCloud.shared.get(.followings(of: $0!)) }
                .eraseToAnyPublisher()
            UserGrid(for: following).navigationTitle(item.title)
        case .playlist(_, let id):
            let ids = SoundCloud.shared.get(.playlist(id))
                .map { $0.trackIDs ?? [] }
                .eraseToAnyPublisher()
            let slice = { ids in
                return SoundCloud.shared.get(.tracks(ids))
            }
            TrackList(for: ids, slice: slice).navigationTitle(item.title)
        }
    }
    
    @ViewBuilder private func navigationDestination<T: SoundCloudIdentifiable>(for element: T) -> some View {
        if let track = element as? Track {
            TrackDetail(track: track)
        }
    }
    
    @ViewBuilder fileprivate func toolbar() -> some View {
        TextField("􀊫 Search", text: $searchQuery)
            .onExitCommand { searchQuery = "" }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(minWidth: 150)
        Button {
            if let user = soundCloud.user {
                navigationPath.append(user)
            }
        } label: {
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
