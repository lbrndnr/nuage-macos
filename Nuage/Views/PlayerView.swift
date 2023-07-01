//
//  PlayerView.swift
//  Nuage
//
//  Created by Laurin Brandner on 26.12.19.
//  Copyright © 2019 Laurin Brandner. All rights reserved.
//

import SwiftUI
import Combine
import StackNavigationView
import SoundCloud

struct NoTrackError: Error {}

struct PlayerView: View {
    
    @EnvironmentObject private var player: StreamPlayer
    @Environment(\.colorScheme) private var colorScheme
    @State private var subscriptions = Set<AnyCancellable>()
    
    var body: some View {
        let duration = TimeInterval(player.currentStream?.duration ?? 0)
        
        return HStack {
            if let track = player.currentStream {
                StackNavigationLink(destination: TrackDetail(track: track)) {
                    RemoteImage(url: player.currentStream?.artworkURL, cornerRadius: 3)
                        .frame(width: 50, height: 50)
                }
            }
            
            let font = Font.system(size: 12).monospacedDigit()
            WaveformSlider(waveform: player.currentStream?.waveform, value: $player.progress, in: 0...duration, minValueLabel: { progress in
                Text(format(time: progress))
                    .font(font)
                    .frame(width: 50, alignment: .trailing)
            }, maxValueLabel: { _ in
                Text(format(time: duration))
                    .font(font)
                    .frame(width: 50, alignment: .leading)
            })
            .foregroundColor(controlColor)
            
            Button(action: player.advanceBackward) {
                Image(systemName: "backward.end.fill")
            }
            .buttonStyle(BorderlessButtonStyle())
            .frame(width: 20, height: 20)
            .foregroundColor(controlColor)
            
            Button(action: player.togglePlayback) {
                let playStateImageName = player.isPlaying ? "pause.fill" : "play.fill"
                Image(systemName: playStateImageName)
            }
            .buttonStyle(BorderlessButtonStyle())
            .frame(width: 20, height: 20)
            .foregroundColor(controlColor)
            
            Button(action: player.advanceForward) {
                Image(systemName: "forward.end.fill")
            }
            .buttonStyle(BorderlessButtonStyle())
            .frame(width: 20, height: 20)
            .foregroundColor(controlColor)
            
            Spacer()
                .frame(width: 30)
            
            Button(action: {
                player.volume = 0
            }, label: {
                Image(systemName: "speaker.fill")
            }).buttonStyle(BorderlessButtonStyle())
            .foregroundColor(controlColor)
            
            PlayerSlider(value: $player.volume, in: 0...1, updateStrategy: .incremental(0.05))
                .frame(width: 100)
            Button(action: {
                player.volume = 1
            }, label: {
                Image(systemName: "speaker.wave.3.fill")
            }).buttonStyle(BorderlessButtonStyle())
            .foregroundColor(controlColor)
        }
        .padding(.all)
        .frame(height: 60)
        .background(backgroundColor)
    }
    
    private var backgroundColor: Color { colorScheme == .light ? .white : Color(hex: 0x1A1A1A) }
    
    private var controlColor: Color { colorScheme == .light ? Color(hex: 0xBFBFBF) : Color(hex: 0x5B5B5B) }
    
}

struct PlayerView_Previews: PreviewProvider {
    
    static var previews: some View {
        let player = StreamPlayer()
        player.enqueue(Preview.tracks)
        
        return PlayerView().environmentObject(player)
    }
    
}
