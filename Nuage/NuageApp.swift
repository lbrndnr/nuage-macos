//
//  NuageApp.swift
//  Nuage
//
//  Created by Laurin Brandner on 06.12.20.
//

import SwiftUI
import Combine

private let accessTokenKey = "accessToken"
private let userKey = "user"

class Commands: ObservableObject {
    
    var filter = PassthroughSubject<(), Never>()
    var search = PassthroughSubject<(), Never>()
    
}

@main
struct NuageApp: App {
    
    private var player = StreamPlayer()
    private var commands = Commands()
    @State private var loggedIn: Bool
    private var subscriptions = Set<AnyCancellable>()
    
    var body: some Scene {
        WindowGroup {
            if loggedIn {
                MainView()
                    .environmentObject(player)
                    .environmentObject(commands)
            }
            else {
                LoginView { accessToken in
                    UserDefaults.standard.set(accessToken, forKey: accessTokenKey)
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
        let size = 500*1024*1024
        URLCache.shared = URLCache(memoryCapacity: size, diskCapacity: size)
        URLSession.shared.configuration.requestCachePolicy = .returnCacheDataElseLoad
        
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: userKey) {
            SoundCloud.shared.user = try? JSONDecoder().decode(User.self, from: data)
        }
        let token = defaults.object(forKey: accessTokenKey)
        
        if let token = token as? String {
            SoundCloud.shared.accessToken = token
            _loggedIn = State(initialValue: true)
        }
        else {
            _loggedIn = State(initialValue: false)
        }
        
        SoundCloud.shared.$user.sink { user in
            if let user = user {
                let data = try? JSONEncoder().encode(user)
                defaults.set(data, forKey: userKey)
            }
            else {
                defaults.set(nil, forKey: userKey)
            }
        }
        .store(in: &subscriptions)
    }
    
}
