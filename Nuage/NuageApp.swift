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
            SoundCloud.shared.user = try? JSONDecoder().decode(User.self, from: data)
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
