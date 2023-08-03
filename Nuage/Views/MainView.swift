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
    
    @AppStorage("sidebarSelection") private var sidebarSelection: SidebarItem = .stream
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
                    let presentSearch: Binding<Bool> = Binding(
                        get: { searchQuery.count > 0 },
                        set: { if !$0 { searchQuery = "" } }
                    )
                    
                    root(for: sidebarSelection)
                        .navigationDestinationWithPlaybackContext(for: Track.self) { TrackDetail(track: $0) }
                        .navigationDestination(for: User.self) { UserDetail(user: $0) }
                        .navigationDestination(for: URL.self) { URLDetail(url: $0) }
                        .navigationDestination(isPresented: presentSearch) {
                            let search = soundCloud.get(.search(searchQuery))
                            SearchList(for: search)
                                .id(searchQuery)
                        }
                }
            }
            if player.queue.count > 0 {
                Divider()
                PlayerView {
                    if let track = player.currentStream, navigationPath != blockingNavigationPath {
                        navigationPath.append(track)
                        blockingNavigationPath = navigationPath
                    }
                }
            }
        }
        .toolbar(content: toolbar)
        .touchBar { TouchBar() }
        .onOpenURL { url in
            guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
            
            components.scheme = "https"
            guard let newURL = components.url else { return }
            navigationPath.append(newURL)
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
        Group {
            switch item {
            case .stream:
                let stream = SoundCloud.shared.get(.stream(), limit: 50)
                PostList(for: stream)
            case .likes:
                let likes = SoundCloud.shared.$user.filter { $0 != nil}
                    .flatMap { SoundCloud.shared.get(.trackLikes(of: $0!), limit: 50) }
                    .eraseToAnyPublisher()
                TrackList(for: likes)
            case .history:
                let history = SoundCloud.shared.get(.history(), limit: 50)
                TrackList(for: history)
            case .following:
                let following = SoundCloud.shared.$user.filter { $0 != nil }
                    .flatMap { SoundCloud.shared.get(.followings(of: $0!), limit: 50) }
                    .eraseToAnyPublisher()
                UserGrid(for: following)
            case .playlist(_, let id):
                TrackList(for: id)
            }
        }
            .navigationTitle(item.title)
            .id(item.id) // Set id so that SwiftUI knows when to render new view
    }
    
    @ViewBuilder fileprivate func toolbar() -> some View {
        HStack{
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(nsColor: .secondaryLabelColor))
            TextField("Search", text: $searchQuery)
                .onExitCommand { searchQuery = "" }
                .textFieldStyle(PlainTextFieldStyle())
                .frame(minWidth: 150)
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 3)
        .background(content: {
            // TODO: Implememnt background selection
        })
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray, lineWidth: 0.5).cornerRadius(6))
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
