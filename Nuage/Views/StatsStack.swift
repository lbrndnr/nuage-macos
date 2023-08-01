//
//  StatsStack.swift
//  Nuage
//
//  Created by Laurin Brandner on 01.08.23.
//

import SwiftUI
import SoundCloud

struct StatsStack: View {
    
    private var track: Track
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "play.fill")
            Text(String(track.playbackCount))
            
            Spacer().frame(width: 2)
            
            Image(systemName: "heart.fill")
            Text(String(track.likeCount))
            
            Spacer().frame(width: 2)
            
            Image(systemName: "arrow.triangle.2.circlepath")
            Text(String(track.repostCount))
        }
    }
    
    init(for track: Track) {
        self.track = track
    }
    
}
