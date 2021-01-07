//
//  TrackView.swift
//  Nuage
//
//  Created by Laurin Brandner on 18.11.20.
//  Copyright © 2020 Laurin Brandner. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct TrackView: View {
    
    var track: Track
    
    var body: some View {
        let duration = format(duration: TimeInterval(track.duration))
        
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading) {
                WebImage(url: track.artworkURL)
                    .resizable()
                    .placeholder { Rectangle().foregroundColor(.gray) }
                    .frame(width: 100, height: 100)
                    .cornerRadius(6)
                Spacer()
                HStack {
                    Button(action: { }) {
                        Image(systemName: "heart")
                    }.buttonStyle(BorderlessButtonStyle())
                    Button(action: { }) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }.buttonStyle(BorderlessButtonStyle())
                }
            }
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
                Text(duration)
                    .foregroundColor(Color(NSColor.secondaryLabelColor))
                Spacer()
                    .frame(height: 8)

                if let description = track.description {
                    let text = description.trimmingCharacters(in: .whitespacesAndNewlines)
                        .replacingOccurrences(of: "\n", with: " ")
                    Text(text)
                }
            }
        }
        .padding(6)
        .navigationTitle(track.title)
    }
    
}
