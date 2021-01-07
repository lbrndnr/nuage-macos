//
//  StreamPlayer.swift
//  Nuage
//
//  Created by Laurin Brandner on 25.12.19.
//  Copyright © 2019 Laurin Brandner. All rights reserved.
//

import AppKit
import AVFoundation
import Combine
import MediaPlayer
import SDWebImage

protocol Streamable {
    
    func prepare() -> AnyPublisher<AVURLAsset, Error>
    
}

private let volumeKey = "volume"
    
class StreamPlayer: ObservableObject {
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var player: AVPlayer
    private var queue = [Track]()
    private var currentItemIndex: Int? {
        didSet {
            currentStream = self.currentItemIndex.map { queue[$0] }
        }
    }
    
    @Published private(set) var currentStream: Track?
    
    @Published var volume: Float = 0.5 {
        didSet {
            if volume > 1 { volume = 1 }
            else if volume < 0 { volume = 0 }
            
            player.volume = volume
            UserDefaults.standard.set(volume, forKey: volumeKey)
        }
    }
    
    private var shouldSeek = true
    @Published var progress: TimeInterval = 0.0 {
        didSet {
            if shouldSeek {
                player.seek(to: CMTime(seconds: progress, preferredTimescale: 1))
            }
        }
    }
    
    @Published private(set) var isPlaying = false {
        didSet {
            MPNowPlayingInfoCenter.default().playbackState = isPlaying ? .playing : .paused
        }
    }
    
    // MARK: - Initialization
    
    init() {
        self.player = AVPlayer()
        self.player.allowsExternalPlayback = false
        
        let defaults = UserDefaults.standard
        if defaults.object(forKey: volumeKey) != nil {
            self.volume = defaults.float(forKey: volumeKey)
        }
        
        let interval = CMTime(value: 1, timescale: 1)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.shouldSeek = false
            self.progress = time.seconds
            self.shouldSeek = true
        }
        
        player.publisher(for: \.timeControlStatus)
            .map { $0 != .paused }
            .assign(to: \.isPlaying, on: self)
            .store(in: &subscriptions)
        
        MPRemoteCommandCenter.shared().playCommand.addTarget { _ in
            self.resume()
            return .success
        }
        
        MPRemoteCommandCenter.shared().pauseCommand.addTarget { _ in
            self.pause()
            return .success
        }
        
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.addTarget { _ in
            self.togglePlayback()
            return .success
        }
        
        MPRemoteCommandCenter.shared().seekForwardCommand.addTarget { _ in
            self.advanceForward()
            return .success
        }
        
        MPRemoteCommandCenter.shared().seekBackwardCommand.addTarget { _ in
            self.advanceBackward()
            return .success
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Playback
    
    func togglePlayback() {
        if isPlaying {
            pause()
        }
        else {
            resume()
        }
    }

    func resume(from index: Int? = nil) {
        guard let idx = index ?? currentItemIndex else { return }
        
        if player.currentItem != nil && currentItemIndex == idx {
            player.play()
        }
        else {
            queue[idx].prepare()
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { print($0) }, receiveValue: { [weak self] asset in
                    guard let self = self else { return }
                    
                    let item = AVPlayerItem(asset: asset)
                    self.player.replaceCurrentItem(with: item)
                    self.player.play()
                    self.currentItemIndex = idx
                    
                    NotificationCenter.default.addObserver(self, selector: #selector(self.advanceForward), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: item)
                    
                    var info: [String: Any] = [
                        MPMediaItemPropertyTitle: self.currentStream?.title ?? "",
                        MPMediaItemPropertyAssetURL: asset.url,
                        MPMediaItemPropertyPlaybackDuration: self.currentStream?.duration ?? 0,
                    ]
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = info
                    
                    if let artworkURL = self.currentStream?.artworkURL {
                        SDWebImageManager.shared.loadImage(with: artworkURL, options: .lowPriority, progress: nil) { (image, data, error, cacheType, finished, url) in
                            if let image = image {
                                let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in return image }
                                info[MPMediaItemPropertyArtwork] = artwork
                                MPNowPlayingInfoCenter.default().nowPlayingInfo = info
                            }
                        }
                    }
                }).store(in: &subscriptions)
        }
    }

    func pause() {
        player.pause()
    }
    
    @objc func advanceForward() {
        guard let idx = currentItemIndex else { return }
        player.replaceCurrentItem(with: nil)
        resume(from: idx + 1)
    }
    
    func advanceBackward() {
        guard let idx = currentItemIndex else { return }
        
        if player.currentTime() < CMTime(value: 15, timescale: 1) {
            player.replaceCurrentItem(with: nil)
            if idx > 0 {
                resume(from: idx - 1)
            }
            else {
                currentItemIndex = nil
            }
        }
        else {
            player.seek(to: .zero)
        }
    }
    
    func seekForward() {
        let time = player.currentTime() + CMTime(seconds: 15, preferredTimescale: 1)
        player.seek(to: time)
    }
    
    func seekBackward() {
        let time = player.currentTime() - CMTime(seconds: 15, preferredTimescale: 1)
        player.seek(to: time)
    }
    
    func reset() {
        pause()
        player.replaceCurrentItem(with: nil)
        queue = []
        currentItemIndex = nil
    }
    
    func enqueue(_ streams: [Track], playNext: Bool = false) {
        guard streams.count > 0 else { return }
        
        if playNext {
            queue = streams + queue
        }
        else {
            queue = queue + streams
        }
    }
    
}
