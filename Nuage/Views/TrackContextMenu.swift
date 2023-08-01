//
//  TrackContextMenu.swift
//  Nuage
//
//  Created by Laurin Brandner on 04.12.20.
//  Copyright © 2020 Laurin Brandner. All rights reserved.
//

import SwiftUI
import Combine
import SoundCloud

private struct TrackContextMenu: ViewModifier {
    
    @ObservedObject private var soundCloud = SoundCloud.shared
    
    var track: Track
    
    @State private var subscriptions = Set<AnyCancellable>()
    
    @EnvironmentObject private var player: StreamPlayer
    @Environment(\.playlists) private var playlists: [AnyPlaylist]
    @Environment(\.toggleLikeTrack) private var toggleLike: (Track) -> () -> ()
    @Environment(\.toggleRepostTrack) private var toggleRepost: (Track) -> () -> ()
    @Environment(\.onPlay) private var onPlay: () -> ()
    
    func body(content: Content) -> some View {
        content.contextMenu {
            Button("Play", action: onPlay)
            Button("Add to Queue") {
                player.enqueue([track])
            }
            Divider()
            Button("Go to User") {
                print("haha")
            }
            Divider()
            Button("Like", action: toggleLike(track))
            Button("Repost", action: toggleRepost(track))
            Menu("Add to Playlist") {
                Button("New Playlist") {
                    print("new playlist lel")
                }

                let playlists = playlists
                    .compactMap { $0.userPlaylist }
                    .filter { $0.secretToken != nil }
                if playlists.count > 0 {
                    Divider()
                    ForEach(playlists, id: \.id) { playlist in
                        Button(playlist.title) {
                            let newTrackID = Int(track.id)!
                            
                            soundCloud.get(.playlist(playlist.id))
                                .map { ($0.trackIDs ?? []).map { Int($0)! } }
                                .flatMap { soundCloud.get(.set(playlist, trackIDs: $0 + [newTrackID])) }
                                .receive(on: RunLoop.main)
                                .sink(receiveCompletion: { _ in
                                }, receiveValue: { success in
                                    print("added track to playlist: \(success)")
                                }).store(in: &subscriptions)
                        }
                    }
                }
            }
            Divider()
            Button("Copy Link") {
                let text = track.permalinkURL.absoluteString
                NSPasteboard.general.declareTypes([.string], owner: nil)
                NSPasteboard.general.setString(text, forType: .string)
            }
        }
    }

}

extension View {
    
    func trackContextMenu(with track: Track) -> some View {
        return modifier(TrackContextMenu(track: track))
    }
    
}

struct OnPlayKey: EnvironmentKey {
    
    static let defaultValue: () -> () = { }
    
}

private struct QueueKey: EnvironmentKey {
    
    static let defaultValue = [Any]()
    
}

extension EnvironmentValues {
    
    fileprivate var queue: [Any] {
        get { self[QueueKey.self] }
        set { self[QueueKey.self] = newValue }
    }

    var onPlay: () -> () {
        get { self[OnPlayKey.self] }
        set { self[OnPlayKey.self] = newValue }
    }
    
}

private struct PlaybackStart<T: SoundCloudIdentifiable>: ViewModifier {
    
    var element: T
    var transform: (T) -> [Track]
    
    @Environment(\.queue) private var queue: [Any]
    @EnvironmentObject private var player: StreamPlayer
    
    func body(content: Content) -> some View {
        content
            .environment(\.onPlay, onPlay)
    }
    
    private func onPlay() {
        guard let elements = queue as? [T], !elements.isEmpty else {
            print("Tried to play a track with an empty queue.")
            return
        }
        
        let idx = elements.firstIndex(of: element)
        guard let idx = idx else {
            print("Tried to play a track that is not in the current queue.")
            return
        }
        
        let allTracks = elements.flatMap(transform)
        let startIndex = elements
            .prefix(upTo: idx)
            .flatMap(transform)
            .count
        
        play(allTracks, from: startIndex, with: player)
    }

}

extension View {
    
    func queue(_ elements: [Any]) -> some View {
        return environment(\.queue, elements)
    }
    
    func playbackStart<T: SoundCloudIdentifiable>(at element: T, transform: @escaping (T) -> [Track]) -> some View {
        return modifier(PlaybackStart(element: element, transform: transform))
    }
    
    func playbackStart(at track: Track) -> some View {
        return modifier(PlaybackStart(element: track, transform: { [$0] }))
    }
    
    func playbackStart(at post: Post) -> some View {
        return modifier(PlaybackStart(element: post, transform: { $0.tracks }))
    }
    
}

