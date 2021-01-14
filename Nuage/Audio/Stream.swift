//
//  Stream.swift
//  Nuage
//
//  Created by Laurin Brandner on 26.12.19.
//  Copyright © 2019 Laurin Brandner. All rights reserved.
//

import AVFoundation
import Combine

struct NoStreamError: Error {}

extension Track: Streamable {
    
    func prepare() -> AnyPublisher<AVURLAsset, Error> {
        guard let url = streamURL else { return Fail(error: NoStreamError()).eraseToAnyPublisher() }
        return SoundCloud.shared.get(.audioFile(url))
            .map { AVURLAsset(url: $0) }
            .eraseToAnyPublisher()
    }
    
}
