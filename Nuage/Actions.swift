//
//  Actions.swift
//  Nuage
//
//  Created by Laurin Brandner on 25.12.20.
//

import SwiftUI
import Combine

private var subscriptions = Set<AnyCancellable>()

func toggleLike(_ track: Track)  {
    SoundCloud.shared.perform(.like(track))
        .receive(on: RunLoop.main)
        .sink(receiveCompletion: { _ in
        }, receiveValue: { success in
            print("liked track:", success)
        }).store(in: &subscriptions)
}

func play(_ tracks: [Track], from idx: Int, on player: StreamPlayer) {
    player.reset()
    player.enqueue(tracks)
    player.resume(from: idx)
}
