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
    
    @State private var track: Track
    @State private var waveform: Waveform
    
    @State private var subscriptions = Set<AnyCancellable>()
    
    var body: some View {
        let duration = format(duration: TimeInterval(track.duration))
        
        VStack(alignment: .leading) {
            HStack(alignment: .bottom, spacing: 10) {
                VStack(alignment: .leading) {
                    Artwork(url: track.artworkURL) { }
                        .frame(width: 100, height: 100)
                    
                }
                if let waveform = waveform {
                    WaveformView(waveform: waveform)
                        .frame(height: 80)
                }
            }
            HStack {
                Image(systemName: "play.fill")
                Text(String(track.playbackCount))
                Image(systemName: "heart.fill")
                Text(String(track.likeCount))
                Image(systemName: "arrow.triangle.2.circlepath")
                Text(String(track.repostCount))
            }.foregroundColor(Color(NSColor.secondaryLabelColor))
            
            HStack {
                Button(action: { }) {
                    Image(systemName: "heart")
                }.buttonStyle(BorderlessButtonStyle())
                Button(action: { }) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }.buttonStyle(BorderlessButtonStyle())
            }
            
            Text(duration)
                .foregroundColor(Color(NSColor.secondaryLabelColor))
            Spacer()
                .frame(height: 8)
            
            CommentList(for: SoundCloud.shared.get(.comments(of: track)))
                .header {
                    if let description = track.description {
                        let text = description.trimmingCharacters(in: .whitespacesAndNewlines)
                            .replacingOccurrences(of: "\n", with: " ")
                        Text(text)
                    }
                }
        }
        .padding(16)
        .navigationTitle(track.title)
        .onAppear {
            SoundCloud.shared.get(.waveform(of: track))
                .replaceError(with: waveform)
                .receive(on: RunLoop.main)
                .assign(to: \.waveform, on: self)
                .store(in: &subscriptions)
        }
    }
    
    init(track: Track) {
        self._track = State(initialValue: track)
        self._waveform = State(initialValue: Waveform(width: 1800, height: 80, repeatedSample: 2))
    }
    
}
