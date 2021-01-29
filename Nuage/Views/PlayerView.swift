//
//  PlayerView.swift
//  Nuage
//
//  Created by Laurin Brandner on 26.12.19.
//  Copyright © 2019 Laurin Brandner. All rights reserved.
//

import SwiftUI

struct PlayerView: View {
    
    @EnvironmentObject private var player: StreamPlayer
    
    var body: some View {
        let duration = TimeInterval(player.currentStream?.duration ?? 0)
        
        return HStack {
            if let track = player.currentStream {
                StackNavigationLink(destination: TrackView(track: track)) {
                    RemoteImage(url: player.currentStream?.artworkURL, width: 50, height: 50, cornerRadius: 3)
                    VStack {
                        Text(player.currentStream?.title ?? "")
                            .frame(maxWidth: 100, alignment: .leading)
                    }
                }
            }
            
            HStack {
                Text(format(duration: player.progress))
                    .multilineTextAlignment(.trailing)
                Slider(value: $player.progress, in: 0...duration)
                Text(format(duration: duration))
            }
            Button(action: player.advanceBackward) {}
                .buttonStyle(FillableSysteImageStyle(systemImageName: "backward.end"))
                .frame(width: 20, height: 20)
            
            let playStateImageName = player.isPlaying ? "pause" : "play"
            Button(action: player.togglePlayback) {}
                .buttonStyle(FillableSysteImageStyle(systemImageName: playStateImageName))
                .frame(width: 20, height: 20)
            
            Button(action: player.advanceForward) {}
                .buttonStyle(FillableSysteImageStyle(systemImageName: "forward.end"))
                .frame(width: 20, height: 20)
            Spacer()
                .frame(width: 30)
            Button(action: {
                player.volume = 0
            }, label: {
                Image(systemName: "speaker.fill")
            }).buttonStyle(BorderlessButtonStyle())
            Slider(value: $player.volume, in: 0...1)
                .frame(width: 100)
            Button(action: {
                player.volume = 1
            }, label: {
                Image(systemName: "speaker.wave.3.fill")
            }).buttonStyle(BorderlessButtonStyle())
        }
        .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        .frame(height: 60)
    }
    
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView().environmentObject(StreamPlayer())
    }
}
