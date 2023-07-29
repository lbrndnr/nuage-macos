//
//  PlayerView.swift
//  Nuage
//
//  Created by Laurin Brandner on 26.12.19.
//  Copyright © 2019 Laurin Brandner. All rights reserved.
//

import SwiftUI
import Combine
import SoundCloud

struct NoTrackError: Error {}

struct PlayerView: View {
    
    var onArtworkTap: () -> ()
    
    @State private var showingVolumeControls = false
    @State private var showingQueue = false
    @State private var subscriptions = Set<AnyCancellable>()
    
    @EnvironmentObject private var player: StreamPlayer
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            let url = player.currentStream?.artworkURL ?? player.currentStream?.user.avatarURL
            RemoteImage(url: url, cornerRadius: 0)
            
            HStack(spacing: 16) {
                artwork()
                    .aspectRatio(1.0, contentMode: .fit)
                    .padding(.vertical, 8)
                
                trackDetails()
                    .frame(width: 80)
                
                progressSlider()
                    .padding(.vertical)
                
                playbackControls()
                
                Spacer()
                    .frame(width: 2)
            }
            .padding(.horizontal, 8)
            .background(.thinMaterial)
        }
        .frame(height: 60)
    }
    
    @ViewBuilder private func artwork() -> some View {
        if let track = player.currentStream {
            let url = track.artworkURL ?? player.currentStream?.user.avatarURL
            RemoteImage(url: url, cornerRadius: 3)
                .onTapGesture(perform: onArtworkTap)
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
    }
    
    @ViewBuilder private func playbackControls() -> some View {
        HStack(spacing: 16) {
            Button(action: player.advanceBackward) {
                resizableImage(name: "backward.fill")
            }
            .buttonStyle(.borderless)
            
            Button(action: player.togglePlayback) {
                let playStateImageName = player.isPlaying ? "pause.fill" : "play.fill"
                resizableImage(name: playStateImageName)
            }
            .buttonStyle(.borderless)
            .keyboardShortcut(.space, modifiers: [])
            
            Button(action: player.advanceForward) {
                resizableImage(name: "forward.fill")
            }
            .buttonStyle(.borderless)
            
            Button(action: {
                showingVolumeControls = true
            }) {
                resizableImage(name: "speaker.wave.2.fill")
            }
            .buttonStyle(.borderless)
            .if(showingVolumeControls) { $0.foregroundColor(.primary) }
            .popover(isPresented: $showingVolumeControls, content: volumeControls)
            
            Button(action: { self.showingQueue.toggle() }) {
                resizableImage(name: "text.line.first.and.arrowtriangle.forward")
            }
            .buttonStyle(.borderless)
            .if(showingQueue) { $0.foregroundColor(.primary) }
            .popover(isPresented: $showingQueue, content: queue)
        }
    }
    
    @ViewBuilder private func volumeControls() -> some View {
        HStack(spacing: 6) {
            Button(action: {
                player.volume = 0
            }, label: {
                resizableImage(name: "speaker.fill", height: 13, width: nil)
            })
            .focusable(false)
            .buttonStyle(.borderless)
            
            PlayerSlider(value: $player.volume, in: 0...1, updateStrategy: .incremental(0.05))
                .frame(width: 100)
            
            Button(action: {
                player.volume = 1
            }, label: {
                resizableImage(name: "speaker.wave.3.fill", height: 13, width: nil)
            })
            .focusable(false)
            .buttonStyle(.borderless)
        }.padding()
    }
    
    @ViewBuilder private func queue() -> some View {
        let currentStreamIndex = player.currentStreamIndex ?? 0
        
        ScrollViewReader { proxy in
            List {
                if currentStreamIndex > 0 {
                    let prefix = player.queue.prefix(upTo: currentStreamIndex)
                    Section(header: Text("Previous")) {
                        queueRows(for: prefix)
                    }
                }
                
                Section(header: Text("Now Playing")) {
                    queueRows(for: [player.queue[currentStreamIndex]])
                }
                
                if currentStreamIndex < player.queue.count - 1 {
                    let suffix = player.queue.suffix(from: currentStreamIndex+1)
                    Section(header: Text("Up Next")) {
                        queueRows(for: suffix)
                    }
                }
            }
            .onAppear {
                if let id = player.currentStream?.id {
                    proxy.scrollTo(id, anchor: .top)
                }
            }
        }
    }
    
    @ViewBuilder private func queueRows<T: RandomAccessCollection>(for tracks: T) -> some View where T.Element == Track {
        ForEach(Array(tracks.enumerated()), id: \.element.id) { idx, track in
            HStack {
                Artwork(url: track.artworkURL ?? track.user.avatarURL, onPlay: {
                    play(Array(tracks), from: idx, on: player)
                })
                .frame(width: 60, height: 60)
                VStack(alignment: .leading) {
                    Text(track.user.displayName)
                        .bold()
                    Text(track.title)
                        .foregroundColor(.secondary)
                }
            }
            Divider()
        }
    }
    
    @ViewBuilder private func resizableImage(name: String, height: CGFloat? = 15, width: CGFloat? = 15) -> some View {
        Image(systemName: name)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width, height: height)
    }
    
}

struct PlayerView_Previews: PreviewProvider {
    
    static var previews: some View {
        let player = StreamPlayer()
        player.enqueue(Preview.tracks)
        
        return PlayerView(onArtworkTap: {}).environmentObject(player)
    }
    
}
