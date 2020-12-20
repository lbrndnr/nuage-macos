//
//  TrackList.swift
//  Nuage
//
//  Created by Laurin Brandner on 23.12.19.
//  Copyright © 2019 Laurin Brandner. All rights reserved.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI
import SoundCloud

struct TrackList<Element: Decodable&Identifiable>: View {
    
    var publisher: InfinitePublisher<Element>
    private var transform: (Element) -> Track
    
    @EnvironmentObject private var player: StreamPlayer
    @State private var subscriptions = Set<AnyCancellable>()
    
    var body: some View {
        InfinteList(publisher: publisher) { elements, idx -> AnyView in
            let track = transform(elements[idx])
            
            let toggleLikeCurrentTrack = {
                self.toggleLike(track)
            }
            let repostCurrentTrack = {
//                onRepost(track)
            }
            let play = {
                let tracks = elements.map(transform)
                self.play(tracks, from: idx)
            }

            return AnyView(VStack(alignment: .leading) {
                TrackRow(track: track, onLike: toggleLikeCurrentTrack, onReblog: repostCurrentTrack)
                Divider()
            }
            .onTapGesture(count: 2, perform: play)
            .trackContextMenu(track: track, onPlay: play))
        }
    }
    
    init(publisher: AnyPublisher<Slice<Element>, Error>, transform: @escaping (Element) -> Track) {
        self.publisher = .slice(publisher)
        self.transform = transform
    }
    
    init(arrayPublisher: AnyPublisher<[Int], Error>,
         slicePublisher: @escaping ([Int]) -> AnyPublisher<[Element], Error>,
         transform: @escaping (Element) -> Track) {
        self.publisher = .array(arrayPublisher, slicePublisher)
        self.transform = transform
    }
    
    private func toggleLike(_ track: Track)  {
        SoundCloud.shared.perform(.like(track))
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { success in
                print("liked track:", success)
            }).store(in: &subscriptions)
    }

    private func play(_ tracks: [Track], from idx: Int) {
        player.reset()
        player.enqueue(tracks)
        player.resume(from: idx)
    }
    
}

extension TrackList where Element == Track {
    
    init(publisher: AnyPublisher<Slice<Track>, Error>) {
        self.init(publisher: publisher) { $0 }
    }
    
    init(arrayPublisher: AnyPublisher<[Int], Error>,
         slicePublisher: @escaping ([Int]) -> AnyPublisher<[Track], Error>) {
        self.init(arrayPublisher: arrayPublisher, slicePublisher: slicePublisher, transform: { $0 })
    }
    
}

extension TrackList where Element == Like<Track> {
    
    init(publisher: AnyPublisher<Slice<Like<Track>>, Error>) {
        self.init(publisher: publisher) { $0.item }
    }
    
}

extension TrackList where Element == HistoryItem {
    
    init(publisher: AnyPublisher<Slice<HistoryItem>, Error>) {
        self.init(publisher: publisher) { $0.track }
    }
    
}

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
        
        return HStack(alignment: .top, spacing: 10) {
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
                    Text(text)
                }
            }
        }.frame(height: 120)
        .fixedSize(horizontal: false, vertical: true)
        .padding(6)
    }

}

//extension TrackRow: Equatable {
//
//    static func == (lhs: TrackRow, rhs: TrackRow) -> Bool {
//        return lhs.track == rhs.track
//    }
//
//
//}

//struct TrackList_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackList(publisher: previewTrackPublisher.collect().eraseToAnyPublisher())
//    }
//}
