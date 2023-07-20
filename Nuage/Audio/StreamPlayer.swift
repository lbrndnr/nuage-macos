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
import URLImage
import SoundCloud

protocol Streamable {
    
    func prepare() -> AnyPublisher<AVURLAsset, Error>
    
}

private let volumeKey = "volume"
    
class StreamPlayer: ObservableObject {
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var player: AVPlayer
    private(set) var queue = [Track]()
    private(set) var currentStreamIndex: Int? {
        didSet {
            currentStream = self.currentStreamIndex.map { queue[$0] }
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
                let time = CMTime(seconds: progress, preferredTimescale: 1)
                player.seek(to: time)
                updateNowPlayingProgress(to: time)
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
        
        $currentStream
            .filter { track in
                guard let track = track else { return false }
                return track.waveform == nil
            }
            .flatMap { track -> AnyPublisher<Waveform?, Error> in
                return SoundCloud.shared.get(.waveform(track!.waveformURL)).map { Optional($0) }.eraseToAnyPublisher()
            }
            .replaceError(with: nil)
            .receive(on: RunLoop.main)
            .sink { waveform in
                self.currentStream?.waveform = waveform
            }
            .store(in: &subscriptions)
        
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
        
        player.publisher(for: \.timeControlStatus)
            .sink(receiveValue: updateNowPlayingPlaybackStatus)
            .store(in: &subscriptions)
        
        addRemoteCommandTargets()
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
        guard let idx = index ?? currentStreamIndex else { return }
        
        if player.currentItem != nil && currentStreamIndex == idx {
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
                    self.currentStreamIndex = idx
                    
                    NotificationCenter.default.addObserver(self, selector: #selector(self.advanceForward), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: item)
                    
                    self.updateNowPlayingInfo()
                }).store(in: &subscriptions)
        }
    }

    func pause() {
        player.pause()
    }
    
    @objc func advanceForward() {
        guard let idx = currentStreamIndex else { return }
        player.replaceCurrentItem(with: nil)
        if queue.count > idx + 1 {
            resume(from: idx + 1)
        }
        else {
            queue = []
            pause()
        }
    }
    
    func advanceBackward() {
        guard let idx = currentStreamIndex else { return }
        
        if player.currentTime() < CMTime(value: 15, timescale: 1) {
            player.replaceCurrentItem(with: nil)
            if idx > 0 {
                resume(from: idx - 1)
            }
            else {
                currentStreamIndex = nil
            }
        }
        else {
            player.seek(to: .zero)
        }
    }
    
    func seekForward() {
        progress += 15
    }
    
    func seekBackward() {
        progress -= 15
    }
    
    func reset() {
        pause()
        player.replaceCurrentItem(with: nil)
        queue = []
        currentStreamIndex = nil
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
    
    // MARK: - MPNowPlayingInfoCenter
    
    private func addRemoteCommandTargets() {
        let center = MPRemoteCommandCenter.shared()
        center.togglePlayPauseCommand.addTarget { _ in
            self.togglePlayback()
            return .success
        }
        
        center.nextTrackCommand.addTarget { _ in
            self.advanceForward()
            return .success
        }
        
        center.previousTrackCommand.addTarget { _ in
            self.advanceBackward()
            return .success
        }
        
        center.changePlaybackPositionCommand.addTarget { event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            self.progress = event.positionTime
            return .success
        }
    }
    
    private func updateNowPlayingInfo() {
        let center = MPNowPlayingInfoCenter.default()
        guard let currentStream = currentStream else {
            center.nowPlayingInfo = nil
            return
        }
        
        var info: [String: Any] = [
            MPMediaItemPropertyPersistentID: currentStream.id,
            MPMediaItemPropertyTitle: currentStream.title,
            MPMediaItemPropertyArtist: currentStream.user.username,
            MPMediaItemPropertyAssetURL: currentStream.permalinkURL,
            MPMediaItemPropertyPlaybackDuration: currentStream.duration,
            MPNowPlayingInfoPropertyPlaybackProgress: Float(player.currentTime().seconds)/currentStream.duration
        ]
        center.nowPlayingInfo = info
        
        let url = currentStream.artworkURL ?? currentStream.user.avatarURL
        URLImageService.shared.remoteImagePublisher(url)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { imageInfo in
                let image = NSImage(cgImage: imageInfo.cgImage, size: imageInfo.size)
                let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in return image }
                info[MPMediaItemPropertyArtwork] = artwork
                
                center.nowPlayingInfo = info
            })
            .store(in: &self.subscriptions)
    }
    
    private func updateNowPlayingPlaybackStatus(for status: AVPlayer.TimeControlStatus) {
        let center = MPNowPlayingInfoCenter.default()
        switch status {
        case .paused: center.playbackState = .paused
        case .playing: center.playbackState = .playing
        case .waitingToPlayAtSpecifiedRate: center.playbackState = .interrupted
        default: center.playbackState = .unknown
        }
    }
    
    private func updateNowPlayingProgress(to time: CMTime) {
        let center = MPNowPlayingInfoCenter.default()
        guard var info = center.nowPlayingInfo else {
            updateNowPlayingInfo()
            return
        }
        
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time.seconds
        center.nowPlayingInfo = info
    }
    
}
