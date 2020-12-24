//
//  NuageApp.swift
//  Nuage
//
//  Created by Laurin Brandner on 06.12.20.
//

import SwiftUI
import SoundCloud

private let accessTokenKey = "accessToken"

@main
struct NuageApp: App {
    
    private let player = StreamPlayer()
    @State private var loggedIn: Bool
    
    var body: some Scene {
        WindowGroup {
            if loggedIn {
                MainView().environmentObject(player)
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
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: "user") {
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
    }
    
}
