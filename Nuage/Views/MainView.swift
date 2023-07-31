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

struct Token: Identifiable, Equatable {
    
    var id: String { key }
    
    var key: String
    var value: String
    var separator: String
    var excluding: Bool
    
    var text: String {
        return key + separator + value
    }
    
    init(key: String, separator: String = ":", excluding: Bool = true) {
        self.key = key
        self.separator = separator
        self.value = ""
        self.excluding = excluding
    }
    
    func with(value: String) -> Token {
        var newToken = self
        newToken.value = value
        
        return newToken
    }
    
}

let allTokens = [Token(key: "User"), Token(key: "Track"), Token(key: "Playlist"), Token(key: "Album"), Token(key: "", separator: "#", excluding: false)]

struct MainView: View {
    
    @ObservedObject private var soundCloud = SoundCloud.shared
    
    @AppStorage("sidebarSelection") private var sidebarSelection: SidebarItem = .stream
    @State private var navigationPath = NavigationPath()
    @State private var blockingNavigationPath: NavigationPath?
    
    @State private var searchQuery = ""
    @State private var searchTokens = [Token]()
    
    private var suggestedTokens: [Token] {
        guard !searchQuery.isEmpty else { return [] }
        
        // Only consider tokens that are not excluding each other
        let hasExcludingToken = searchTokens.contains { $0.excluding }
        let availableTokens = hasExcludingToken ? allTokens.filter { !$0.excluding } : allTokens
        
        // Check if the user is typing a token
        let typedToken = availableTokens.compactMap { token -> Token? in
            let length = token.text.lengthOfBytes(using: .utf8)
            guard token.text.lowercased().starts(with: searchQuery.lowercased().prefix(length)) else { return nil }
            
            let components = searchQuery.components(separatedBy: token.separator)
            guard let value = components.last, components.count == 2 else { return token }
            
            return token.with(value: value)
        }
        guard typedToken.isEmpty else { return typedToken }
        
        return availableTokens.map { $0.with(value: searchQuery) }
    }
    
    @State private var subscriptions = Set<AnyCancellable>()
    
    @EnvironmentObject private var commands: Commands
    @EnvironmentObject private var player: StreamPlayer
    @Environment(\.playlists) private var playlists: [AnyPlaylist]
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationSplitView(sidebar: sidebar) {
                NavigationStack(path: $navigationPath) {
                    let presentSearch: Binding<Bool> = Binding(
                        get: { searchQuery.count > 0 || searchTokens.count > 0 },
                        set: { if !$0 { searchQuery = ""; searchTokens = [] } }
                    )
                    
                    root(for: sidebarSelection)
                        .navigationDestination(for: Track.self) { TrackDetail(track: $0) }
                        .navigationDestination(for: User.self) { UserDetail(user: $0) }
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
        .searchable(text: $searchQuery, tokens: $searchTokens, suggestedTokens: .constant(suggestedTokens), prompt: Text("Search")) { Text($0.text) }
        .onSubmit(of: .search) {
            if suggestedTokens.count == 1 {
                searchTokens.append(suggestedTokens[0])
                searchQuery = ""
            }
        }
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
                let ids = SoundCloud.shared.get(.playlist(id))
                    .map { $0.trackIDs ?? [] }
                    .eraseToAnyPublisher()
                let slice = { ids in
                    return SoundCloud.shared.get(.tracks(ids))
                }
                TrackList(for: ids, slice: slice)
            }
        }
            .navigationTitle(item.title)
            .id(item.id) // Set id so that SwiftUI knows when to render new view
    }
    
    @ViewBuilder fileprivate func toolbar() -> some View {
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
