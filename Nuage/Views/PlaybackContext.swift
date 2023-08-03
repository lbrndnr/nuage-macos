//
//  PlaybackContext.swift
//  Nuage
//
//  Created by Laurin Brandner on 02.08.23.
//

import SwiftUI
import SoundCloud

struct OnPlayKey: EnvironmentKey {
    
    static let defaultValue: () -> () = { }
    
}

private struct PlaybackContextKey: EnvironmentKey {
    
    static let defaultValue = [AnyHashable]()
    
}

extension EnvironmentValues {
    
    var playbackContext: [AnyHashable] {
        get { self[PlaybackContextKey.self] }
        set { self[PlaybackContextKey.self] = newValue }
    }

    var onPlay: () -> () {
        get { self[OnPlayKey.self] }
        set { self[OnPlayKey.self] = newValue }
    }
    
}

private struct PlaybackStart<T: SoundCloudIdentifiable>: ViewModifier {
    
    var element: T
    var transform: (T) -> [Track]
    
    @Environment(\.playbackContext) private var playbackContext: [AnyHashable]
    @EnvironmentObject private var player: StreamPlayer
    
    func body(content: Content) -> some View {
        content
            .environment(\.onPlay, onPlay)
    }
    
    private func onPlay() {
        guard let elements = playbackContext as? [T] else {
            print("Tried to play an element of type \(T.self) in an non-matching playback context.")
            return
        }
                
        guard !playbackContext.isEmpty else {
            print("Tried to play a track with an empty playback context.")
            return
        }
        
        let idx = elements.firstIndex(of: element)
        guard let idx = idx else {
            print("Tried to play a track that is not in the current playback context.")
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
    
    func playbackContext(_ elements: [AnyHashable]) -> some View {
        return environment(\.playbackContext, elements)
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

private struct PlaybackPathComponent<V: Hashable>: Hashable {
    
    var value: V
    var playbackContext: [AnyHashable]
    var onPlay: () -> ()
    
    static func == (lhs: PlaybackPathComponent, rhs: PlaybackPathComponent) -> Bool {
        return lhs.value == rhs.value && lhs.playbackContext == rhs.playbackContext
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(value.hashValue)
        hasher.combine(playbackContext.hashValue)
    }
    
}

struct PlaybackNavigationLink<Value, Label> : View where Value: Hashable, Label : View {
    
    private var value: Value
    private var label: Label
    
    @Environment(\.playbackContext) private var playbackContext: [AnyHashable]
    @Environment(\.onPlay) private var onPlay: () -> ()

    var body: some View {
        let pathValue = PlaybackPathComponent(value: value, playbackContext: playbackContext, onPlay: onPlay)
        NavigationLink(value: pathValue) { label }
    }
    
    init(value: Value, @ViewBuilder label: () -> Label) {
        self.value = value
        self.label = label()
    }
    
}

extension View {
    
    func navigationDestinationWithPlaybackContext<D, C>(for data: D.Type, @ViewBuilder destination: @escaping (D) -> C) -> some View where D : Hashable, C : View {
        return navigationDestination(for: PlaybackPathComponent<D>.self) { comp in
            destination(comp.value)
                .environment(\.playbackContext, comp.playbackContext)
                .environment(\.onPlay, comp.onPlay)
        }
    }
    
}
