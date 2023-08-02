//
//  URLDetail.swift
//  Nuage
//
//  Created by Laurin Brandner on 02.08.23.
//

import SwiftUI
import SoundCloud
import Combine

struct URLDetail: View {
    
    var url: URL
    @State private var item: Some?
    
    @State private var subscriptions = Set<AnyCancellable>()
    
    var body: some View {
        switch item {
        case nil: loadingIndicator()
        case .track(let track): TrackDetail(track: track)
                .playbackContext([track])
                .playbackStart(at: track)
        case .user(let user): UserDetail(user: user)
        case .userPlaylist(let playlist): TrackList(for: playlist.id)
        case .systemPlaylist(let playlist): TrackList(for: playlist.id)
        }
    }
    
    @ViewBuilder private func loadingIndicator() -> some View {
        ProgressView()
            .progressViewStyle(.circular)
            .onAppear {
                SoundCloud.shared.get(.resolve(url))
                    .map { Optional($0) }
                    .replaceError(with: nil)
                    .receive(on: RunLoop.main)
                    .assign(to: \.item, on: self)
                    .store(in: &subscriptions)
            }
    }
    
}
