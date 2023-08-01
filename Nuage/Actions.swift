//
//  Actions.swift
//  Nuage
//
//  Created by Laurin Brandner on 25.12.20.
//

import SwiftUI
import Combine
import SoundCloud

func play(_ tracks: [Track], from idx: Int, with player: StreamPlayer, animated: Bool = true) {
    let animation = player.queue.count > 0 ? nil : Animation.default
    
    withAnimation(animation) {
        player.reset()
        player.enqueue(tracks)
        player.resume(from: idx)
    }
}
