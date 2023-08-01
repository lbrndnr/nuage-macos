//
//  TrackDetail.swift
//  Nuage
//
//  Created by Laurin Brandner on 18.11.20.
//  Copyright © 2020 Laurin Brandner. All rights reserved.
//

import SwiftUI
import Combine
import SoundCloud

struct TrackDetail: View {
    
    private var track: Track
    @State private var waveform: Waveform
    
    @State private var subscriptions = Set<AnyCancellable>()
    
    var body: some View {
        let duration = format(time: track.duration)
        let url = track.artworkURL ?? track.user.avatarURL
        
        VStack(alignment: .leading) {
            Text(track.title)
                .font(.title)
                .lineLimit(2)
            
            Spacer()
                .frame(height: 2)
            
            HStack {
                NavigationLink(value: track.user) {
                    Text(track.user.username)
                        .foregroundColor(.secondary)
                        .font(.title2)
                }
                .buttonStyle(.plain)
                
                Spacer()
                    .frame(width: 16)
                
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
                .foregroundColor(.secondary)
                
            }
            
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading) {
                    Artwork(url: track.artworkURL) { }
                        .frame(width: 100, height: 100)
                    
                }
                
                WaveformView(with: waveform)
                    .foregroundColor(.secondary)
                    .frame(height: 80)
            }
            
            HStack {
                Button(action: { }) {
                    Image(systemName: "heart")
                }.buttonStyle(.borderless)
                Button(action: { }) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }.buttonStyle(.borderless)
            }
            
            Text(duration)
                .foregroundColor(Color(NSColor.secondaryLabelColor))
            Spacer()
                .frame(height: 8)
            
            Divider()
            
            CommentList(for: SoundCloud.shared.get(.comments(of: track)))
                .header {
                    if let description = track.description {
                        Text(description.withAttributedLinks())
                    }
                }
        }
        .padding(16)
        .navigationTitle(track.title)
        .onAppear {
            SoundCloud.shared.get(.waveform(track.waveformURL))
                .replaceError(with: waveform)
                .receive(on: RunLoop.main)
                .assign(to: \.waveform, on: self)
                .store(in: &subscriptions)
        }
    }
    
    init(track: Track) {
        self.track = track
        self._waveform = State(initialValue: Waveform(samples: Array(repeating: 1800, count: 2)))
    }
    
}

struct TrackDetail_Previews: PreviewProvider {
    
    static var previews: some View {
        let player: StreamPlayer = {
            let player = StreamPlayer()
            player.enqueue(Preview.tracks)
            
            return player
        }()
        
        TrackDetail(track: Preview.tracks.first!)
            .environmentObject(player)
            .environmentObject(Commands())
    }
    
}
