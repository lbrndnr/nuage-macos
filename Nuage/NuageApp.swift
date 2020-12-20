//
//  NuageApp.swift
//  Nuage
//
//  Created by Laurin Brandner on 06.12.20.
//

import SwiftUI

@main
struct NuageApp: App {
    
    private let player = StreamPlayer()
    
    var body: some Scene {
        WindowGroup {
            if SoundCloud.shared.accessToken == nil {
                LoginView {}
            }
            else {
                MainView().environmentObject(player)
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
        let token = defaults.object(forKey: "access_token") as? String
        
        if let token = token {
            SoundCloud.shared.accessToken = token
//            showMainWindow()
        }
        else {
//            showLoginWindow {
//                self.window?.close()
//                self.window = nil
//                self.showMainWindow()
//            }
        }
    }
    
}
