//
//  SearchList.swift
//  Nuage
//
//  Created by Laurin Brandner on 25.12.20.
//

import SwiftUI
import Combine
import SoundCloud

private enum SearchSection: String {
    case users
    case tracks
    case playlists
}

struct SearchList: View {
    
    var publisher: AnyPublisher<Page<Some>, Error>
    
    private var userPublisher: AnyPublisher<[User], Error> {
        publisher.map { page in
            return page.collection.compactMap { elem in
                switch elem {
                case .user(let user): return user
                default: return nil
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private var trackPublisher: AnyPublisher<[Track], Error> {
        publisher.map { page in
            return page.collection.compactMap { elem in
                switch elem {
                case .track(let track): return track
                default: return nil
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private var playlistPublisher: AnyPublisher<[UserPlaylist], Error> {
        publisher.map { page in
            return page.collection.compactMap { elem in
                switch elem {
                case .userPlaylist(let playlist): return playlist
                default: return nil
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    @State private var users = [User]()
    @State private var tracks = [Track]()
    @State private var playlists = [UserPlaylist]()
    
    @State private var subscriptions = Set<AnyCancellable>()
    
    var body: some View {
        Group {
            if users.isEmpty && tracks.isEmpty && playlists.isEmpty {
                ProgressView()
                    .progressViewStyle(.circular)
            }
            else {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        if !users.isEmpty {
                            Section(content: {
                                HStack(alignment: .top) {
                                    ForEach(users) { UserItem(user: $0) }
                                }
                            }, header: header(for: .users), footer: footer)
                        }
                        if !tracks.isEmpty {
                            Section(content: {
                                VStack(alignment: .leading) {
                                    ForEach(tracks) { track in
                                        TrackRow(track: track)
                                            .playbackStart(at: track)
                                    }
                                }
                                .playbackContext(tracks)
                            }, header: header(for: .tracks), footer: footer)
                        }
                        if !playlists.isEmpty {
                            Section(content: {
                                VStack(alignment: .leading) {
                                    ForEach(playlists) { playlist in
                                        PlaylistRow(playlist: playlist)
                                    }
                                }
                                .playbackContext(playlists)
                            }, header: header(for: .playlists), footer: footer)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Search")
        .onAppear {
            userPublisher.replaceError(with: [])
                .receive(on: RunLoop.main)
                .assign(to: \.users, on: self)
                .store(in: &subscriptions)
            
            trackPublisher.replaceError(with: [])
                .receive(on: RunLoop.main)
                .assign(to: \.tracks, on: self)
                .store(in: &subscriptions)
            
            playlistPublisher.replaceError(with: [])
                .receive(on: RunLoop.main)
                .assign(to: \.playlists, on: self)
                .store(in: &subscriptions)
        }
    }
    
    private func header(for section: SearchSection) -> () -> some View {
        @ViewBuilder func buildHeader() -> some View {
            NavigationLink(value: "lol") {
                Text(section.rawValue.capitalized)
                    .font(.title)
                Image(systemName: "chevron.right.square.fill")
            }
            .buttonStyle(.plain)
        }
        return buildHeader
    }
    
    @ViewBuilder private func footer() -> some View {
        Spacer(minLength: 20)
        Divider()
        Spacer(minLength: 20)
    }
    
}
