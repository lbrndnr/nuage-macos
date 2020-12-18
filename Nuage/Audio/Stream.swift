//
//  Stream.swift
//  Nuage
//
//  Created by Laurin Brandner on 26.12.19.
//  Copyright © 2019 Laurin Brandner. All rights reserved.
//

import AVFoundation
import Combine

extension Track: Streamable {
    
    func prepare() -> AnyPublisher<AVURLAsset, Error> {
        return SoundCloud.shared.getMediaURL(with: self.streamURL)
            .mapError { $0 as Error }
            .map { AVURLAsset(url: $0) }
            .eraseToAnyPublisher()
    }
    
}
