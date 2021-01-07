//
//  TrackRow.swift
//  Nuage
//
//  Created by Laurin Brandner on 25.12.20.
//

import SwiftUI
import SDWebImageSwiftUI

struct TrackRow: View {
    
    private var track: Track
    private var onLike: () -> ()
    private var onReblog: () -> ()
    
    init(track: Track, onLike: @escaping () -> (), onReblog: @escaping () -> ()) {
        self.track = track
        self.onLike = onLike
        self.onReblog = onReblog
    }
    
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
                    Button(action: onLike) {
                        Image(systemName: "heart")
                    }.buttonStyle(BorderlessButtonStyle())
                    Button(action: onReblog) {
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
                    Text(text).lineLimit(3)
                }
            }
        }
        .padding(6)
    }

}

extension TrackRow: Equatable {

    static func == (lhs: TrackRow, rhs: TrackRow) -> Bool {
        return lhs.track == rhs.track
    }


}
