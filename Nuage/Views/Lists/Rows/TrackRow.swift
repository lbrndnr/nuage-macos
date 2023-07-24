//
//  TrackRow.swift
//  Nuage
//
//  Created by Laurin Brandner on 25.12.20.
//

import SwiftUI
import Combine
import StackNavigationView
import SoundCloud

struct TrackRow: View {
    
    private var track: Track
    private var onPlay: () -> ()
    
    @State private var subscriptions = Set<AnyCancellable>()
    
    init(track: Track, onPlay: @escaping () -> ()) {
        self.track = track
        self.onPlay = onPlay
    }
    
    var body: some View {
        let duration = format(time: track.duration)
        
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading) {
                Artwork(url: track.artworkURL ?? track.user.avatarURL, onPlay: onPlay)
                    .frame(width: 100, height: 100)
                Spacer()
                FeedbackStack(for: track)
                Spacer()
            }
            VStack(alignment: .leading) {
                Text(track.title)
                    .font(.title3)
                    .bold()
                    .lineLimit(1)
                StackNavigationLink(track.user.displayName, destination: UserDetail(user: track.user))
                    .buttonStyle(.plain)
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
                    Text(text).lineLimit(3)
                }
            }
        }
    }

}
