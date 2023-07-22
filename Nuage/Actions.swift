//
//  Actions.swift
//  Nuage
//
//  Created by Laurin Brandner on 25.12.20.
//

import SwiftUI
import Combine
import SoundCloud

private var subscriptions = Set<AnyCancellable>()

func toggleRepost(_ track: Track) -> () -> () {
    return {
        SoundCloud.shared.perform(.repost(track))
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { success in
                print("reposted track:", success)
            }).store(in: &subscriptions)
    }
}

func toggleRepost(_ playlist: UserPlaylist) -> () -> () {
    return {
        SoundCloud.shared.perform(.repost(playlist))
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { success in
                print("reposted playlist:", success)
            }).store(in: &subscriptions)
    }
}

func play(_ tracks: [Track], from idx: Int, on player: StreamPlayer, animated: Bool = true) {
    let animation = player.queue.count > 0 ? nil : Animation.default
    
    withAnimation(animation) {
        player.reset()
        player.enqueue(tracks)
        player.resume(from: idx)
    }
}
