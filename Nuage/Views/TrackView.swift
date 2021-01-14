//
//  TrackView.swift
//  Nuage
//
//  Created by Laurin Brandner on 18.11.20.
//  Copyright © 2020 Laurin Brandner. All rights reserved.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI

struct TrackView: View {
    
    var track: Track
    @State private var waveform: Waveform?
    
    @State private var subscriptions = Set<AnyCancellable>()
    
    var body: some View {
        let duration = format(duration: TimeInterval(track.duration))
        
        VStack(alignment: .leading) {
            Text(track.title)
                .font(.title3)
                .bold()
            HStack {
                Image(systemName: "play.fill")
                Text(String(track.playbackCount))
                Image(systemName: "heart.fill")
                Text(String(track.likeCount))
                Image(systemName: "arrow.triangle.2.circlepath")
                Text(String(track.repostCount))
            }.foregroundColor(Color(NSColor.secondaryLabelColor))
            
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading) {
                    WebImage(url: track.artworkURL)
                        .resizable()
                        .placeholder { Rectangle().foregroundColor(.gray) }
                        .frame(width: 100, height: 100)
                        .cornerRadius(6)
                    HStack {
                        Button(action: { }) {
                            Image(systemName: "heart")
                        }.buttonStyle(BorderlessButtonStyle())
                        Button(action: { }) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }.buttonStyle(BorderlessButtonStyle())
                    }
                }
                if let waveform = waveform {
                    WaveformView(waveform: waveform)
                        .frame(height: 100)
                }
            }
            
            Text(duration)
                .foregroundColor(Color(NSColor.secondaryLabelColor))
            Spacer()
                .frame(height: 8)

            if let description = track.description {
                let text = description.trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "\n", with: " ")
                Text(text)
            }
            
            Spacer()
        }
        .padding(16)
        .navigationTitle(track.title)
        .onAppear {
            SoundCloud.shared.get(.waveform(of: track))
                .map { Optional($0) }
                .replaceError(with: nil)
                .receive(on: RunLoop.main)
                .assign(to: \.waveform, on: self)
                .store(in: &subscriptions)
        }
    }
    
}
