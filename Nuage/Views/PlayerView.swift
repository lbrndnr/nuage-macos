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
        HStack(spacing: 16) {
            artwork()
                .aspectRatio(1.0, contentMode: .fit)
                .padding(.vertical, 8)
            
            trackDetails()
                .frame(width: 80)
            
            progressSlider()
                .padding(.vertical)
            
            playbackControls()
            
            volumeControls()
        }
        .frame(height: 60)
        .padding(.horizontal, 8)
        .foregroundColor(controlColor)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    @ViewBuilder private func artwork() -> some View {
        if let track = player.currentStream {
            StackNavigationLink(destination: TrackDetail(track: track)) {
                let url = player.currentStream?.artworkURL ?? player.currentStream?.user.avatarURL
                RemoteImage(url: url, cornerRadius: 3)
            }
        }
        else {
            RemoteImage(url: nil, cornerRadius: 3)
        }
    }
    
    @ViewBuilder private func trackDetails() -> some View {
        if let track = player.currentStream {
            VStack(alignment: .leading, spacing: 4) {
                Text(track.user.displayName)
                    .bold()
                    .lineLimit(1)
                Text(track.title)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundColor(.secondary)
            }
        }
        else {
            Spacer()
        }
    }
    
    @ViewBuilder private func progressSlider() -> some View {
        let duration = TimeInterval(player.currentStream?.duration ?? 0)
        let font = Font.system(size: 14).monospacedDigit()
        
        WaveformSlider(waveform: player.currentStream?.waveform, value: $player.progress, in: 0...duration, minValueLabel: { progress in
            Text(format(time: progress))
                .font(font)
                .frame(width: 70, alignment: .trailing)
        }, maxValueLabel: { _ in
            Text(format(time: duration))
                .font(font)
                .frame(width: 70, alignment: .leading)
        })
        .foregroundColor(controlColor)
    }
    
    @ViewBuilder private func playbackControls() -> some View {
        HStack(spacing: 16) {
            Button(action: player.advanceBackward) {
                Image(systemName: "backward.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: player.togglePlayback) {
                let playStateImageName = player.isPlaying ? "pause.fill" : "play.fill"
                Image(systemName: playStateImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: player.advanceForward) {
                Image(systemName: "forward.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    @ViewBuilder private func volumeControls() -> some View {
        Button(action: {
            player.volume = 0
        }, label: {
            Image(systemName: "speaker.fill")
        })
        .buttonStyle(PlainButtonStyle())
        
        PlayerSlider(value: $player.volume, in: 0...1, updateStrategy: .incremental(0.05))
            .frame(width: 100)
        Button(action: {
            player.volume = 1
        }, label: {
            Image(systemName: "speaker.wave.3.fill")
        })
        .buttonStyle(PlainButtonStyle())
    }
    
    private var controlColor: Color { colorScheme == .light ? Color(hex: 0xBFBFBF) : Color(hex: 0x5B5B5B) }
    
}

struct PlayerView_Previews: PreviewProvider {
    
    static var previews: some View {
        let player = StreamPlayer()
        player.enqueue(Preview.tracks)
        
        return PlayerView().environmentObject(player)
    }
    
}
