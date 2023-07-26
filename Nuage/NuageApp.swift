//
//  NuageApp.swift
//  Nuage
//
//  Created by Laurin Brandner on 06.12.20.
//

import SwiftUI
import Combine
import SoundCloud

private let accessTokenKey = "accessToken"
private let accessTokenExpiryDateKey = "accessTokenExpiryDate"
private let userKey = "user"
private let playlistsKey = "playlists"
private let likesKey = "likes"
private let postsKey = "posts"

struct PlaylistKey: EnvironmentKey {
    
    static let defaultValue = [AnyPlaylist]()
    
}

struct LikesKey: EnvironmentKey {
    
    static let defaultValue = [Track]()
    
}

struct PostsKey: EnvironmentKey {
    
    static let defaultValue = [Post]()
    
}


struct ToggleLikeTrackKey: EnvironmentKey {
    
    static let defaultValue: (Track) -> () -> () = { _ in return { fatalError("Did not set the toggleLike action") } }
    
}

struct ToggleRepostTrackKey: EnvironmentKey {
    
    static let defaultValue: (Track) -> () -> () = { _ in return { fatalError("Did not set the toggleRepost action") } }
    
}


struct ToggleLikePlaylistKey: EnvironmentKey {
    
    static let defaultValue: (AnyPlaylist) -> () -> () = { _ in return { fatalError("Did not set the toggleLike action") } }
    
}

struct ToggleRepostPlaylistKey: EnvironmentKey {
    
    static let defaultValue: (UserPlaylist) -> () -> () = { _ in return { fatalError("Did not set the toggleRepost action") } }
    
}

extension EnvironmentValues {
    
    var playlists: [AnyPlaylist] {
        get { self[PlaylistKey.self] }
        set { self[PlaylistKey.self] = newValue }
    }
    
    var likes: [Track] {
        get { self[LikesKey.self] }
        set { self[LikesKey.self] = newValue }
    }
    
    var posts: [Post] {
        get { self[PostsKey.self] }
        set { self[PostsKey.self] = newValue }
    }
    
    var toggleLikeTrack: (Track) -> () -> () {
        get { self[ToggleLikeTrackKey.self] }
        set { self[ToggleLikeTrackKey.self] = newValue }
    }
    
    var toggleRepostTrack: (Track) -> () -> () {
        get { self[ToggleRepostTrackKey.self] }
        set { self[ToggleRepostTrackKey.self] = newValue }
    }
    
    var toggleLikePlaylist: (AnyPlaylist) -> () -> () {
        get { self[ToggleLikePlaylistKey.self] }
        set { self[ToggleLikePlaylistKey.self] = newValue }
    }
    
    var toggleRepostPlaylist: (UserPlaylist) -> () -> () {
        get { self[ToggleRepostPlaylistKey.self] }
        set { self[ToggleRepostPlaylistKey.self] = newValue }
    }
    
}


class Commands: ObservableObject {
    
    var filter = PassthroughSubject<(), Never>()
    var search = PassthroughSubject<(), Never>()
    
}

@main
struct NuageApp: App {
    
    private var player = StreamPlayer()
    private var commands = Commands()
    
    @State private var playlists: [AnyPlaylist]
    @State private var likes: [Track]
    @State private var posts: [Post]
    @State private var loggedIn: Bool
    @State private var subscriptions = Set<AnyCancellable>()
    
    var body: some Scene {
        WindowGroup {
            if loggedIn {
                MainView()
                    .environmentObject(player)
                    .environmentObject(commands)
                    .environment(\.playlists, playlists)
                    .environment(\.likes, likes)
                    .environment(\.posts, posts)
                    .environment(\.toggleLikeTrack, toggleLike)
                    .environment(\.toggleRepostTrack, toggleRepost)
                    .environment(\.toggleLikePlaylist, toggleLike)
                    .environment(\.toggleRepostPlaylist, toggleRepost)
                    .onAppear {
                        reloadLibrary()
                        reloadLikes()
                        reloadPosts()
                    }
            }
            else {
                LoginView { accessToken, expiryDate in
                    let defaults = UserDefaults.standard
                    defaults.set(accessToken, forKey: accessTokenKey)
                    defaults.set(expiryDate, forKey: accessTokenExpiryDateKey)
                    SoundCloud.shared.accessToken = accessToken
                    loggedIn = true
                }
            }
        }
        .commands {
            SidebarCommands()
            CommandGroup(after: .textEditing) {
                Button("Filter") {
                    commands.filter.send()
                }.keyboardShortcut("f", modifiers: .command)
                Button("Search") {
                    commands.search.send()
                }.keyboardShortcut("l", modifiers: .command)
            }
            CommandMenu("Playback") {
                let playbackToggleTitle = player.isPlaying ? "Pause" : "Play"
                Button(playbackToggleTitle, action: player.togglePlayback)
                .keyboardShortcut(.space, modifiers: [])
                
                Divider()
                
                Button("Next", action: player.advanceForward)
                .keyboardShortcut(.rightArrow, modifiers: .command)
                
                Button("Previous", action: player.advanceBackward)
                .keyboardShortcut(.leftArrow, modifiers: .command)
                
                Button("Seek Forward", action: player.seekForward)
                .keyboardShortcut(.rightArrow, modifiers: [.command, .shift])
                
                Button("Seek Backward", action: player.seekBackward)
                .keyboardShortcut(.leftArrow, modifiers: [.command, .shift])
                
                Divider()
                
                Button("Volume Up") {
                    player.volume += 0.05
                }
                .keyboardShortcut(.upArrow, modifiers: [.command])
                
                Button("Volume Down") {
                    player.volume -= 0.05
                }
                .keyboardShortcut(.downArrow, modifiers: [.command])
            }
        }
    }
    
    init() {
        let MB = 1024*1024
        URLCache.shared = URLCache(memoryCapacity: 10*MB, diskCapacity: 20*MB)
        URLSession.shared.configuration.requestCachePolicy = .returnCacheDataElseLoad
        
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: userKey) {
            do {
                SoundCloud.shared.user = try JSONDecoder().decode(User.self, from: data)
            }
            catch {
                defaults.removeObject(forKey: userKey)
                print("Failed to load user from UserDefaults: \(error)")
            }
        }
        let token = defaults.object(forKey: accessTokenKey)
        let expiryDate = defaults.object(forKey: accessTokenExpiryDateKey)
        
        _loggedIn = State(initialValue: false)
        if let token = token as? String {
            if let exipryDate = expiryDate as? Date, exipryDate < Date() {
                defaults.set(nil, forKey: accessTokenKey)
                defaults.set(nil, forKey: accessTokenExpiryDateKey)
            }
            else {
                SoundCloud.shared.accessToken = token
                _loggedIn = State(initialValue: true)
            }
        }
        
        if let data = defaults.data(forKey: playlistsKey) {
            playlists = try! JSONDecoder().decode([AnyPlaylist].self, from: data)
        }
        else {
            playlists = []
        }
        
        if let data = defaults.data(forKey: likesKey) {
            likes = try! JSONDecoder().decode([Track].self, from: data)
        }
        else {
            likes = []
        }
        
        if let data = defaults.data(forKey: postsKey) {
            posts = try! JSONDecoder().decode([Post].self, from: data)
        }
        else {
            posts = []
        }
        
        playlists.publisher.sink { playlists in
            let data = try! JSONEncoder().encode(playlists)
            defaults.set(data, forKey: playlistsKey)
        }
        .store(in: &subscriptions)
        
        likes.publisher.sink { likes in
            let data = try! JSONEncoder().encode(likes)
            defaults.set(data, forKey: likesKey)
        }
        .store(in: &subscriptions)
        
        posts.publisher.sink { posts in
            let data = try! JSONEncoder().encode(posts)
            defaults.set(data, forKey: postsKey)
        }
        .store(in: &subscriptions)
        
        SoundCloud.shared.$user.sink { user in
            if let user = user {
                let data = try! JSONEncoder().encode(user)
                defaults.set(data, forKey: userKey)
            }
            else {
                defaults.set(nil, forKey: userKey)
            }
        }
        .store(in: &subscriptions)
    }
    
    private func reloadLibrary() {
        SoundCloud.shared.get(all: .library())
            .map { $0.map { $0.item } }
            .replaceError(with: playlists)
            .receive(on: RunLoop.main)
            .assign(to: \.playlists, on: self)
            .store(in: &subscriptions)
    }
    
    private func reloadLikes() {
        SoundCloud.shared.$user
            .filter { $0 != nil}
            .flatMap { SoundCloud.shared.get(all: .trackLikes(of: $0!)) }
            .map { $0.map { $0.item } }
            .replaceError(with: likes)
            .receive(on: RunLoop.main)
            .assign(to: \.likes, on: self)
            .store(in: &subscriptions)
    }
    
    private func reloadPosts() {
        SoundCloud.shared.$user
            .filter { $0 != nil}
            .flatMap { SoundCloud.shared.get(all: .stream(of: $0!)) }
            .replaceError(with: posts)
            .receive(on: RunLoop.main)
            .assign(to: \.posts, on: self)
            .store(in: &subscriptions)
    }
    
    private func toggleLike(_ track: Track) -> () -> () {
        return {
            let shouldUnlike = likes.contains(track)
            let request: APIRequest = shouldUnlike ? .unlike(track) : .like(track)
            
            return SoundCloud.shared.perform(request)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    if case let .failure(error) = completion  {
                        print("Failed to like track: \(error)")
                    }
                }, receiveValue: {
                    if shouldUnlike {
                        likes.removeAll { $0 == track }
                    }
                    else {
                        likes.append(track)
                    }
                })
                .store(in: &subscriptions)
        }
    }
    
    private func toggleLike(_ playlist: AnyPlaylist) -> () -> () {
        return {
            let shouldUnlike = playlists.contains(playlist)
            let request: APIRequest = shouldUnlike ? .unlike(playlist) : .like(playlist)
            
            return SoundCloud.shared.perform(request)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    if case let .failure(error) = completion  {
                        print("Failed to like playlist: \(error)")
                    }
                }, receiveValue: {
                    if shouldUnlike {
                        playlists.removeAll { $0 == playlist }
                    }
                    else {
                        playlists.append(playlist)
                    }
                })
                .store(in: &subscriptions)
        }
    }
    
    private func toggleRepost(_ track: Track) -> () -> () {
        return {
            let shouldDeleteRepost = posts.filter { $0.isRepost && $0.isTrack }
                .map { $0.tracks.first! }
                .contains(track)
            let request: APIRequest = shouldDeleteRepost ? .unrepost(track) : .repost(track)
            
            return SoundCloud.shared.perform(request)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    if case let .failure(error) = completion  {
                        print("Failed to repost track: \(error)")
                    }
                }, receiveValue: { reloadPosts() })
                .store(in: &subscriptions)
        }
    }
    
    private func toggleRepost(_ playlist: UserPlaylist) -> () -> () {
        return {
            let shouldDeleteRepost = posts.filter { $0.isRepost && !$0.isTrack }
                .compactMap { $0.playlist }
                .contains(playlist)
            
            let request: APIRequest = shouldDeleteRepost ? .unrepost(playlist) : .repost(playlist)
            
            return SoundCloud.shared.perform(request)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    if case let .failure(error) = completion  {
                        print("Failed to repost playlist: \(error)")
                    }
                }, receiveValue: { reloadPosts() })
                .store(in: &subscriptions)
        }
    }
    
}
